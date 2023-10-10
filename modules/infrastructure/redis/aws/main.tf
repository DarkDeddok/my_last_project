data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.context.app_name}-redis-subnetgroup"
  subnet_ids = "${var.subnet_ids}"
}

resource "aws_security_group" "redis" {
  name        = "${var.context.app_name}-redis"
  description = "Managed by Terraform"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 6379
    to_port   = 6379
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

resource "aws_elasticache_cluster" "default" {
  cluster_id           = "${var.context.app_name}"
  engine               = "redis"
  node_type            = "${var.context.redis.aws.instance_class}"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.4"
  security_group_ids   =["${aws_security_group.redis.id}"]
  apply_immediately    = true
  port                 = 6379
  subnet_group_name    = "${aws_elasticache_subnet_group.redis.name}"
}