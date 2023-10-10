terraform {
  required_version = ">= 0.12.21"
}

provider "aws" {
  version = "~> 3.37.0"
  region  = "${var.context.region}"
}


data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.61.0"

  name                 = "${var.context.app_name}"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.context.app_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.context.app_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.context.app_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "${var.context.app_name}-all_worker_management"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "database" {
  source                = "../../infrastructure/database/aws"
  context               = var.context
  vpc_id                = "${module.vpc.vpc_id}"
  eks_security_group_id = "${aws_security_group.all_worker_mgmt.id}"
  subnet_ids            =          "${module.vpc.private_subnets}"
}

# IAM-5487 - As of 4.2.1.2, we use ES driver 7.15, but AWS supports as high as 7.10, so we can't use AWS ES
#module "elasticsearch" {
#  source                = "../../infrastructure/elasticsearch/aws"
#  context               = var.context
#  vpc_id                = "${module.vpc.vpc_id}"
#  eks_security_group_id = "${aws_security_group.all_worker_mgmt.id}"
#  subnet_ids            =          "${module.vpc.private_subnets}"
#}

# IAM-5487
module "elasticsearch" {
  source = "../../infrastructure/elasticsearch/helm"
  context = var.context
}

# IAM-5487
module "kibana" {
  source = "../../infrastructure/kibana/helm"
  context = var.context
}

module "redis" {
  source                = "../../infrastructure/redis/aws"
  context               = var.context
  vpc_id                = "${module.vpc.vpc_id}"
  subnet_ids            =          "${module.vpc.private_subnets}"
}

module "gremlin" {
  source                = "../../infrastructure/gremlin/aws"
  context               = var.context
  vpc_id                = "${module.vpc.vpc_id}"
  subnet_ids            =          "${module.vpc.private_subnets}"
}

data "aws_eks_cluster" "default" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.default.token
  load_config_file       = false
  version                = "~> 1.13.2"
}

# doesn't work in AWS - EKS creation would attempt to use 'localhost' or whatever the old kube file pointed to
#  no idea why.
#module "kubernetes" {
#  source = "../../kubernetes"
#  kube_host                   = data.aws_eks_cluster.default.endpoint
#  kube_token                  = data.aws_eks_cluster_auth.default.token
#  kube_cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)

#  context = var.context
#}


resource "aws_iam_policy" "eks_worknode_ebs_policy" {
  name = "${var.context.app_name}-CSI"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}


module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "14.0.0"
  cluster_name                         = "${var.context.app_name}"
  cluster_version                      = "1.23"
  subnets                              = "${module.vpc.private_subnets}"
  vpc_id                               = "${module.vpc.vpc_id}"
  cluster_endpoint_public_access       = "${var.context.cluster.aws.cluster_endpoint_public_access}"
  cluster_create_timeout               = "30m"
  worker_groups = [
    {
      instance_type = "${var.context.kubernetes.aws.machine_type}"
      asg_desired_capacity = "${var.context.replica_count}"
      asg_min_size = "${var.context.replica_count}"
      asg_max_size  = "${var.context.replica_count}"
      root_volume_type = "gp2"
    }
  ]
  worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]
  workers_additional_policies=[
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    aws_iam_policy.eks_worknode_ebs_policy.arn
  ]
  map_users = var.context.iam.aws.map_users
  map_roles = var.context.iam.aws.map_roles
}

resource "aws_eks_addon" "csi_addon" {
  cluster_name = "${var.context.app_name}"
  addon_name   = "aws-ebs-csi-driver"
  addon_version = "v1.11.4-eksbuild.1"
  depends_on = [
    module.eks
  ]
}


resource "null_resource" "update_kubeconfig" {

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${var.context.app_name} --region ${var.context.region};
   EOT
  }
  depends_on = [
    module.eks
  ]
}

module "helm" {
  source = "../../helm"
  kube_host                   = data.aws_eks_cluster.default.endpoint
  kube_token                  = data.aws_eks_cluster_auth.default.token
  kube_cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)

  context = var.context
  cloud_provider = "aws"
}

/*
Won't work until AWS supports the ES version we require.
Error:  Exiting: Error importing Kibana dashboards: fail to import the dashboards in Kibana: Error importing directory /usr/share/filebeat/kibana: failed to import Kibana index pattern: Kibana version must be at least 7.14.0
module "monitoring" {
  source = "../../infrastructure/monitoring/helm"
  kube_host                   = data.aws_eks_cluster.default.endpoint
  kube_token                  = data.aws_eks_cluster_auth.default.token
  kube_cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)

  context = var.context

  database = {
    host = "${module.database.database_host}"
    port = "${module.database.database_port}"
    user : "${var.context.database.root.user}"
    password = "${var.context.database.root.password}"
  }

  redis = {
    host = "${module.redis.redis_host}"
    password = "${module.redis.redis_password}"
  }

  rabbitmq = {
    user = "${var.context.rabbitmq.user}"
    password = "${var.context.rabbitmq.password}"
    host = "${module.helm.rabbitmq_hostname}"
  }

  kibana = {
    kibana_port = "${module.elasticsearch.kibana_port}"
    kibana_host = "${module.elasticsearch.kibana_host}"
    kibana_scheme = "${module.elasticsearch.kibana_scheme}"
    kibana_path = "${module.elasticsearch.kibana_path}"
  }

  elasticsearch = {
    host = "${module.elasticsearch.elasticsearch_host}"
    port = "${module.elasticsearch.elasticsearch_port}"
  }

  cloud_provider = "aws"
}
*/

module "openiam-app" {
  source = "../../app"
  kube_host                   = data.aws_eks_cluster.default.endpoint
  kube_token                  = data.aws_eks_cluster_auth.default.token
  kube_cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)

  context = var.context

  database = {
    host = "${module.database.database_host}"
    port = "${module.database.database_port}"
    created_database = "${module.database.database_name}"
    flywayBaselineVersion = "${var.context.database.flywayBaselineVersion}"
    flywayCommand = "${var.context.database.flywayCommand}"
  }

  elasticsearch = {
    host = "${module.elasticsearch.elasticsearch_host}"
    port = "${module.elasticsearch.elasticsearch_port}"
    # IAM-5487
    #kibana_full_url = "${module.elasticsearch.kibana_scheme}://${module.elasticsearch.kibana_host}${module.elasticsearch.kibana_path}"
    kibana_full_url = "${module.kibana.kibana_scheme}://${module.kibana.kibana_host}:${module.kibana.kibana_port}${module.kibana.kibana_path}"
  }

  redis = {
    host = "${module.redis.redis_host}"
    port = "${module.redis.redis_port}"
    mode = "${module.redis.redis_mode}"
  }

  gremlin = {
    host = "${module.gremlin.host}"
    port = "${module.gremlin.port}"
  }

  rabbitmq = {
    user = "${var.context.rabbitmq.user}"
    password = "${var.context.rabbitmq.password}"
    host = "${module.helm.rabbitmq_hostname}"
    cookie_name = "${var.context.rabbitmq.cookie_name}"
  }

  vault = {
    host = "${module.helm.vault_hostname}"
  }

  cloud_provider = "aws"
}
