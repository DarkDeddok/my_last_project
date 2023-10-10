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

resource "helm_release" "kibana" {
  name      = "${var.context.app_name}-kibana"
  repository = "${var.context.mods.elasticsearch}"
  chart      = "kibana"
  version    = "7.16.2"
  namespace = "${var.context.namespace}"
  recreate_pods = true
  wait       = "false"
  count      = "${var.context.kibana.helm.enabled == "true" ? 1 : 0}"

  values = [
    "${file(".deploy/kibana.values.yaml")}"
  ]

  set {
    name = "replicas"
    value = "${var.context.kibana.helm.replicas}"
    type = "string"
  }

  set {
      name = "openiam.appname"
      value = "${var.context.app_name}"
  }
}
