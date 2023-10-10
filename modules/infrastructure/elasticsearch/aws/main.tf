data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "es" {
  name        = "${var.context.app_name}-elasticsearch"

  description = "Elasticsearch Security GroupManaged by Terraform"
  vpc_id      = "${var.vpc_id}"

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "es" {
  description              = "Allow worker nodes to communicate with ES (managed by terraform)"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.es.id}"
  source_security_group_id = "${var.eks_security_group_id}"
  type                     = "ingress"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.context.app_name}"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type = "${var.context.elasticsearch.aws.instance_class}"
    instance_count = "${length(var.subnet_ids)}"
    zone_awareness_enabled = true
    zone_awareness_config {
        availability_zone_count = "${length(var.subnet_ids)}"
    }
  }

  vpc_options {
    subnet_ids = "${var.subnet_ids}"

    security_group_ids = ["${aws_security_group.es.id}"]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  # see https://aws.amazon.com/elasticsearch-service/pricing/
  # this is required for certain instance_classes
  ebs_options {
    ebs_enabled = "${var.context.elasticsearch.aws.ebs_enabled}"
    volume_size = "${var.context.elasticsearch.aws.ebs_volume_size}"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.context.app_name}/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }
}
