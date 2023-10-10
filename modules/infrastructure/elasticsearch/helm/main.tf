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

resource "helm_release" "elasticsearch" {
  name      = "${var.context.app_name}-elasticsearch"
  repository = "${var.context.mods.elasticsearch}"
  chart      = "elasticsearch"
  namespace = "${var.context.namespace}"
  version    = "7.16.2"
  recreate_pods = true
  wait       = "false"

  values = [
    "${file(".deploy/elasticsearch.values.yaml")}"
  ]

  set {
      name = "openiam.appname"
      value = "${var.context.app_name}"
  }

  set {
    name = "esJavaOpts"
    value = "${var.context.elasticsearch.helm.esJavaOpts}"
  }

  set {
    name = "replicas"
    value = "${var.context.elasticsearch.helm.replicas}"
    type = "string"
  }

  set {
    name = "clusterHealthCheckParams"
    value = "wait_for_status=yellow&timeout=10s"
  }

  set {
    name = "volumeClaimTemplate.resources.requests.storage"
    value = "${var.context.elasticsearch.helm.storageSize}"
  }
}
