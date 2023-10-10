provider "helm" {
  version = "~> 1.3.2"

  kubernetes {
    host                   = "${var.kube_host}"
    token                  = "${var.kube_token}"
    client_certificate     = "${var.kube_client_certificate}"
    client_key             = "${var.kube_client_key}"
    cluster_ca_certificate = "${var.kube_cluster_ca_certificate}"
  }
}

provider "google" {
  region = "${var.context.region}"
  version = "~> 2.14"
}

provider "google-beta"{
  region = "${var.context.region}"
  version = "~> 2.14"
}

resource "google_bigtable_instance" "bigtable" {
  provider         = "google-beta"
  name             = "${var.context.app_name}-bigtable"

  cluster {
    cluster_id   = "${var.context.app_name}-bigtable"
    zone         = "${var.context.region}-a"
    num_nodes    = "3"
    storage_type = "SSD"
  }
}

resource "helm_release" "gremlin" {
    name      = "${var.context.app_name}-gremlin"
    chart      = "./openiam-gremlin"
    namespace = "${var.context.namespace}"
    version    = "4.2.1.3"
    recreate_pods = true
    wait       = "false"
    timeout    = 900000

    values = [
      "${file("./.deploy/openiam.gremlin.values.yaml")}"
    ]

    set {
        name = "openiam.appname"
        value = "${var.context.app_name}"
    }

    set {
        name = "openiam.elasticsearch.host"
        value = "${var.elasticsearch.host}"
    }

    set {
        name = "openiam.elasticsearch.port"
        value = "${var.elasticsearch.port}"
    }

    set {
        name = "openiam.cloud_provider"
        value = "gke"
    }

    set {
        name = "openiam.gremlin.replicas"
        value = "${var.context.gremlin.gke.replicas}"
    }

    set {
        name = "openiam.bash.log.level"
        value = "${var.context.logging.level.bash}"
    }

    set {
        name = "openiam.hbase.ext.google.bigtable.instance.id"
        value = "${google_bigtable_instance.bigtable.id}"
    }

    set {
      name = "openiam.elasticsearch.username"
      value = "${var.context.elasticsearch.helm.authentication.username}"
    }

    set {
      name = "openiam.elasticsearch.password"
      value = "${var.context.elasticsearch.helm.authentication.password}"
    }
}
