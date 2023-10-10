provider "kubernetes" {
    version                = "1.13.2"
    host                   = "${var.kube_host}"
    token                  = "${var.kube_token}"
    client_certificate     = "${var.kube_client_certificate}"
    client_key             = "${var.kube_client_key}"
    cluster_ca_certificate = "${var.kube_cluster_ca_certificate}"
}

resource "kubernetes_cluster_role_binding" "required_for_aws" {
  metadata {
    name = "tiller"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
}
