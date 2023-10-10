resource "aws_security_group" "db" {
  name = "${var.context.app_name}-db"

  description = "RDS Security Group (Managed by Terraform)"
  vpc_id = "${var.vpc_id}"

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "db-access" {
  description              = "Allow worker nodes to communicate with database (managed by terraform)"
  from_port                = "${var.context.database.aws.port}"
  to_port                  = "${var.context.database.aws.port}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.db.id}"
  source_security_group_id = "${var.eks_security_group_id}"
  type                     = "ingress"
}

variable "engine_versions" {
  type = "map"

  default = {
    mariadb    = "10.3.31"
    postgres   = "11.4"
    sqlserver-se = "UNSUPPORTED" #"14.00.3049.1.v1"
    sqlserver-ee = "UNSUPPORTED" #"14.00.3049.1.v1"
    sqlserver-ex = "UNSUPPORTED" #"14.00.3049.1.v1"
    sqlserver-web = "UNSUPPORTED" #"14.00.3049.1.v1"
    oracle-ee = "18.0.0.0.ru-2019-07.rur-2019-07.r1"
    oracle-se2 = "18.0.0.0.ru-2019-07.rur-2019-07.r1"
    oracle-se1 = "UNSUPPORTED" #"11.2.0.4.v21"
    oracle-se = "UNSUPPORTED" #"11.2.0.4.v21"
  }
}

variable "major_engine_versions" {
  type = "map"

  default = {
    mariadb    = "10.3"
    postgres   = "11.4"
    sqlserver-se = "UNSUPPORTED" #"14.00"
    sqlserver-ee = "UNSUPPORTED" #"14.00"
    sqlserver-ex = "UNSUPPORTED" #"14.00"
    sqlserver-web = "UNSUPPORTED" #"14.00"
    oracle-ee = "18"
    oracle-se2 = "18"
    oracle-se1 = "UNSUPPORTED" #"11.2"
    oracle-se = "UNSUPPORTED" #"11.2"
  }
}

variable "families" {
  type = "map"

  default = {
    mariadb    = "mariadb10.3"
    postgres   = "postgres11"
    sqlserver-se = "UNSUPPORTED" #"sqlserver-se-14.0"
    sqlserver-ee = "UNSUPPORTED" #"sqlserver-ee-14.0"
    sqlserver-ex = "UNSUPPORTED" #"sqlserver-ex-14.0"
    sqlserver-web = "UNSUPPORTED" #"sqlserver-web-14.0"
    oracle-ee = "oracle-ee-18"
    oracle-se2 = "oracle-se2-18"
    oracle-se1 = "UNSUPPORTED" #"oracle-se1-11.2"
    oracle-se = "UNSUPPORTED" #"oracle-se-11.2"
  }
}

variable "instance_classes" {
  type = "map"

  default = {
    mariadb    = "db.t2.medium"
    postgres   = "db.t2.medium"
    sqlserver-se = "UNSUPPORTED" #"db.m4.large"
    sqlserver-ee = "UNSUPPORTED" #"db.m5.xlarge"
    sqlserver-ex = "UNSUPPORTED" #"db.t2.medium"
    sqlserver-web = "UNSUPPORTED" #"db.t2.medium"
    oracle-ee = "db.m5.large"
    oracle-se2 = "db.m5.large"
    oracle-se1 = "UNSUPPORTED" #"db.m5.large"
    oracle-se = "UNSUPPORTED" #"db.m5.large"
  }
}

variable "licences" {
  type = "map"

  default = {
    mariadb    = ""
    postgres   = ""
    sqlserver-se = "UNSUPPORTED" #"license-included"
    sqlserver-ee = "UNSUPPORTED" #"license-included"
    sqlserver-ex = "UNSUPPORTED" #"license-included"
    sqlserver-web = "UNSUPPORTED" #"license-included"
    oracle-ee = "bring-your-own-license"
    oracle-se2 = "license-included"
    oracle-se1 = "UNSUPPORTED" #"license-included"
    oracle-se = "UNSUPPORTED" #"bring-your-own-license"
  }
}

variable "parameters" {
  type = "map"
  default = {}
}

locals {
  db_parameters = merge(
    var.parameters,
    {
        mariadb    = [
                         {
                           name  = "character_set_client"
                           value = "utf8"
                         },
                         {
                           name  = "character_set_server"
                           value = "utf8"
                         },
                         {
                           name = "max_connections"
                           value = "${35*(var.context.replica_count_map.esb + var.context.replica_count_map.workflow + var.context.replica_count_map.authmanager)}"
                         }
                     ]
       postgres   = [
                         {
                           name  = "client_encoding"
                           value = "utf8"
                         },
                         {
                           name = "max_connections"
                           value = "${35*(var.context.replica_count_map.esb + var.context.replica_count_map.workflow + var.context.replica_count_map.authmanager)}"
                           apply_method = "pending-reboot"
                         }
                    ]
        sqlserver-se = []
        sqlserver-ee = []
        sqlserver-ex = []
        sqlserver-web = []
        oracle-ee = []
        oracle-se2 = []
        oracle-se1 = []
        oracle-se = []
    }
  )
}



module "db" {
  source                               = "terraform-aws-modules/rds/aws"
  version                              = "2.5.0"
  identifier                           = "${var.context.app_name}"
  # if this is mssql, the name must be null
  # if this is oracle, the name is the SID, and it must be CAPITAL letters, otherwise RDS will try to re-create the instance every time
  name                                 = "${lower(var.context.database.type) == "mssql" ? null : (lower(var.context.database.type) == "oracle" ? upper(var.context.database.oracle.sid) : var.context.app_name)}"

  engine            = "${var.context.database.aws.engine}"
  engine_version    = "${length(var.context.database.aws.version) > 0 ? var.context.database.aws.version : var.engine_versions["${var.context.database.aws.engine}"]}"
  family            = "${length(var.context.database.aws.family) > 0 ? var.context.database.aws.family : var.families["${var.context.database.aws.engine}"]}"
  instance_class    = "${length(var.context.database.aws.instance_class) > 0 ? var.context.database.aws.instance_class : var.instance_classes["${var.context.database.aws.engine}"]}"
  license_model     = "${length(var.context.database.aws.license_model) > 0 ? var.context.database.aws.license_model : var.licences["${var.context.database.aws.engine}"]}"
  allocated_storage = "${var.context.database.aws.allocated_storage}"
  storage_type      = "${var.context.database.aws.storage_type}"
  storage_encrypted = false

  username = "${var.context.database.root.user}"
  password = "${var.context.database.root.password}"
  port     = "${var.context.database.aws.port}"

  vpc_security_group_ids = ["${aws_security_group.db.id}"]

  major_engine_version = "${length(var.context.database.aws.major_engine_version) > 0 ? var.context.database.aws.major_engine_version : var.major_engine_versions["${var.context.database.aws.engine}"]}"

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = "${var.context.database.aws.backup_retention_period}"

  multi_az = "${var.context.database.aws.multi_az}"

  # DB subnet group
  subnet_ids = "${var.subnet_ids}"

  final_snapshot_identifier = "${var.context.app_name}"

  deletion_protection = false

  character_set_name = "${lower(var.context.database.type) == "oracle" ? "AL32UTF8" : null}"

  timezone = "Central Standard Time"

  parameters = "${length(var.context.database.aws.parameters) > 0 ? var.context.database.aws.parameters : local.db_parameters["${var.context.database.aws.engine}"]}"

  apply_immediately = true

}
