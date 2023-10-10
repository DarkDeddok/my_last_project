variable "region" {}
variable "app_name" {}
variable "use_longhorn" {}
variable "replica_count" {}
variable "replica_count_map" {}
variable "database" {}

variable "redis" {}
variable "rabbitmq" {}

variable "elasticsearch" {}

variable "logging" {}

variable "rproxy" {}

variable "iam" {}

variable "autodeploy" {}

variable "kubernetes" {}

variable "kibana" {}

variable "metricbeat" {}

variable "filebeat" {}

variable "gremlin" {}

variable "vault" {}

variable "namespace" {}

variable "mods" {}

variable "cassandra" {}

variable "cluster" {}

variable "javaOpts" {}

variable "stash" {}

module "deployment" {
  source = "./modules/core/gke"
  context = {
    namespace = "${var.namespace}"
    region = "${var.region}"
    app_name = "${var.app_name}"
    use_longhorn = var.use_longhorn
    replica_count = "${var.replica_count}"
    replica_count_map = var.replica_count_map
    database = var.database
    redis = var.redis
    rabbitmq = var.rabbitmq
    logging = var.logging
    elasticsearch = var.elasticsearch
    rproxy = var.rproxy
    iam = var.iam
    autodeploy = var.autodeploy
    kubernetes = var.kubernetes
    kibana = var.kibana
    metricbeat = var.metricbeat
    filebeat = var.filebeat
    gremlin = var.gremlin
    vault = var.vault
    mods = var.mods
    cassandra = var.cassandra
    cluster = var.cluster
    javaOpts = var.javaOpts
    stash = var.stash
  }
}


