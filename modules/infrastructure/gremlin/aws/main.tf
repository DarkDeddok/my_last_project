data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

resource "aws_neptune_subnet_group" "gremlin" {
  name       = "${var.context.app_name}-gremlin"
  subnet_ids = "${var.subnet_ids}"

  tags = {
    Name = "Neptune subnet group"
  }
}

resource "aws_security_group" "neptune" {
  name        = "${var.context.app_name}-neptune"
  description = "Managed by Terraform"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 8182
    to_port   = 8182
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_vpc.selected.cidr_block}",
    ]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_neptune_cluster" "gremlin" {
  cluster_identifier                  = "${var.context.app_name}-neptune"
  engine                              = "neptune"
  engine_version                      = "1.1.1.0"
#  availability_zones                  = data.aws_availability_zones.available.names
  backup_retention_period             = 1
  preferred_backup_window             = "07:00-09:00"
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = false
  apply_immediately                   = true
  neptune_subnet_group_name           = "${aws_neptune_subnet_group.gremlin.id}"
  vpc_security_group_ids              = ["${aws_security_group.neptune.id}"]
}

resource "aws_neptune_cluster_instance" "gremlin" {
  count                     = "${var.context.gremlin.aws.replicas}"
  cluster_identifier        = "${aws_neptune_cluster.gremlin.id}"
  engine                    = "neptune"
  instance_class            = "${var.context.gremlin.aws.machine_type}"
  apply_immediately         = true
  publicly_accessible       = false
  neptune_subnet_group_name = "${aws_neptune_subnet_group.gremlin.id}"
}
