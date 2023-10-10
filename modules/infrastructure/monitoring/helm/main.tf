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

resource "helm_release" "metricbeat" {
  name      = "${var.context.app_name}-metricbeat"
  repository = "${var.context.mods.elasticsearch}"
  chart      = "metricbeat"
  namespace = "${var.context.namespace}"
  version    = "7.16.2"
  recreate_pods = true
  wait       = "false"
  count      = "${var.context.metricbeat.helm.enabled == "true" ? 1 : 0}"

  values = [
    "${file(".deploy/metricbeat.values.yaml")}"
  ]

  set {
    name = "replicas"
    value = "${var.context.metricbeat.helm.replicas}"
    type = "string"
  }

  set {
      name = "openiam.appname"
      value = "${var.context.app_name}"
  }

  set {
    name = "extraEnvs[0].name"
    value = "RABBITMQ_HOSTNAME"
  }

  set {
    name = "extraEnvs[0].value"
    value = "${var.rabbitmq.host}"
  }
  set {
    name = "extraEnvs[1].name"
    value = "RABBITMQ_USERNAME"
  }

  set {
    name = "extraEnvs[1].value"
    value = "${var.rabbitmq.user}"
  }

  set {
    name = "extraEnvs[2].name"
    value = "RABBITMQ_PASSWORD"
  }

  set {
    name = "extraEnvs[2].value"
    value = "${var.rabbitmq.password}"
  }

  set {
    name = "extraEnvs[3].name"
    value = "DATABASE_HOST"
  }

  set {
    name = "extraEnvs[3].value"
    value = "${var.database.host}"
  }

  set {
    name = "extraEnvs[4].name"
    value = "DATABASE_PORT"
  }

  set {
    name = "extraEnvs[4].value"
    value = "${var.database.port}"
    type = "string"
  }

  set {
    name = "extraEnvs[5].name"
    value = "DATABASE_PASSWORD"
  }

  set {
    name = "extraEnvs[5].value"
    value = "${var.database.password}"
  }

  set {
    name = "extraEnvs[6].name"
    value = "DATABASE_USERNAME"
  }

  set {
    name = "extraEnvs[6].value"
    value = "${var.database.user}"
  }
  set {
    name = "extraEnvs[7].name"
    value = "REDIS_HOST"
  }

  set {
    name = "extraEnvs[7].value"
    value = "${var.redis.host}"
  }

  set {
    name = "extraEnvs[8].name"
    value = "REDIS_PASSWORD"
  }

  set {
    name = "extraEnvs[8].value"
    value = "${length(var.redis.password) > 0 ? "${var.redis.password}" : ""}"
  }

  set {
    name = "extraEnvs[9].name"
    value = "KIBANA_HOST"
  }

  set {
    name = "extraEnvs[9].value"
    value = "${var.kibana.kibana_host}"
  }

  set {
    name = "extraEnvs[10].name"
    value = "KIBANA_SCHEME"
  }

  set {
    name = "extraEnvs[10].value"
    value = "${var.kibana.kibana_scheme}"
  }

  set {
    name = "extraEnvs[11].name"
    value = "KIBANA_PATH"
  }

  set {
    # communication to the API is done via '/' in non-AWS environments, even with server.basePath is specified in kibana
    name = "extraEnvs[11].value"
    value = "${var.cloud_provider == "aws" ? "${var.kibana.kibana_path}" : ""}"
  }

  set {
    name = "extraEnvs[12].name"
    value = "ELASTICSEARCH_HOSTS"
  }

  set {
    name = "extraEnvs[12].value"
    value = "${var.elasticsearch.host}"
  }

  set {
    name = "extraEnvs[13].name"
    value = "ELASTICSEARCH_PORT"
  }

  set {
    name = "extraEnvs[13].value"
    value = "${var.elasticsearch.port}"
    type = "string"
  }

  set {
    name = "extraEnvs[14].name"
    value = "KIBANA_PORT"
  }

  set {
    name = "extraEnvs[14].value"
    value = "${var.kibana.kibana_port}"
    type = "string"
  }

  set {
    name = "extraEnvs[15].name"
    value = "ELASTICSEARCH_USERNAME"
  }

  set {
    name = "extraEnvs[15].value"
    value = "${var.context.elasticsearch.helm.authentication.username}"
  }

  set {
    name = "extraEnvs[16].name"
    value = "ELASTICSEARCH_PASSWORD"
  }

  set {
    name = "extraEnvs[16].value"
    value = "${var.context.elasticsearch.helm.authentication.password}"
  }

  set {
    name = "daemonset.extraEnvs[0].name"
    value = "ELASTICSEARCH_PASSWORD"
  }

  set {
    name = "daemonset.extraEnvs[0].value"
    value = "${var.context.elasticsearch.helm.authentication.password}"
  }

  set {
    name = "daemonset.extraEnvs[1].name"
    value = "ELASTICSEARCH_USERNAME"
  }

  set {
    name = "daemonset.extraEnvs[1].value"
    value = "${var.context.elasticsearch.helm.authentication.username}"
  }

  set {
    name = "deployment.extraEnvs[0].name"
    value = "ELASTICSEARCH_PASSWORD"
  }

  set {
    name = "deployment.extraEnvs[0].value"
    value = "${var.context.elasticsearch.helm.authentication.password}"
  }

  set {
    name = "deployment.extraEnvs[1].name"
    value = "ELASTICSEARCH_USERNAME"
  }

  set {
    name = "deployment.extraEnvs[1].value"
    value = "${var.context.elasticsearch.helm.authentication.username}"
  }
}

resource "helm_release" "filebeat" {
  name       = "${var.context.app_name}-filebeat"
  repository = "${var.context.mods.elasticsearch}"
  chart      = "filebeat"
  namespace = "${var.context.namespace}"
  version    = "7.16.2"
  recreate_pods = true
  wait       = "false"
  count      = "${var.context.filebeat.helm.enabled == "true" ? 1 : 0}"

  values = [
    "${file(".deploy/filebeat.values.yaml")}"
  ]

  set {
    name = "replicas"
    value = "${var.context.filebeat.helm.replicas}"
    type = "string"
  }

  set {
      name = "openiam.appname"
      value = "${var.context.app_name}"
  }

  set {
    name = "extraEnvs[0].name"
    value = "ELASTICSEARCH_HOST"
  }

  set {
    name = "extraEnvs[0].value"
    value = "${var.elasticsearch.host}"
  }

  set {
    name = "extraEnvs[1].name"
    value = "ELASTICSEARCH_PORT"
  }

  set {
    name = "extraEnvs[1].value"
    value = "${var.elasticsearch.port}"
    type = "string"
  }

  set {
    name = "extraEnvs[2].name"
    value = "KIBANA_HOST"
  }

  set {
    name = "extraEnvs[2].value"
    value = "${var.kibana.kibana_host}"
  }

  set {
    name = "extraEnvs[3].name"
    value = "KIBANA_SCHEME"
  }

  set {
    name = "extraEnvs[3].value"
    value = "${var.kibana.kibana_scheme}"
  }

  set {
    name = "extraEnvs[4].name"
    value = "KIBANA_PATH"
  }

  set {
    name = "extraEnvs[4].value"
    # communication to the API is done via '/' in non-AWS environments, even with server.basePath is specified in kibana
    value = "${var.cloud_provider == "aws" ? "${var.kibana.kibana_path}" : ""}"
  }

  set {
    name = "extraEnvs[5].name"
    value = "KIBANA_PORT"
  }

  set {
    name = "extraEnvs[5].value"
    value = "${var.kibana.kibana_port}"
    type = "string"
  }

  set {
    name = "extraEnvs[6].name"
    value = "ELASTICSEARCH_PASSWORD"
  }

  set {
    name = "extraEnvs[6].value"
    value = "${var.context.elasticsearch.helm.authentication.password}"
  }

  set {
    name = "extraEnvs[7].name"
    value = "ELASTICSEARCH_USERNAME"
  }

  set {
    name = "extraEnvs[7].value"
    value = "${var.context.elasticsearch.helm.authentication.username}"
  }

  set {
    name = "daemonset.extraEnvs[0].name"
    value = "ELASTICSEARCH_PASSWORD"
  }

  set {
    name = "daemonset.extraEnvs[0].value"
    value = "${var.context.elasticsearch.helm.authentication.password}"
  }

  set {
    name = "daemonset.extraEnvs[1].name"
    value = "ELASTICSEARCH_USERNAME"
  }

  set {
    name = "daemonset.extraEnvs[1].value"
    value = "${var.context.elasticsearch.helm.authentication.username}"
  }

  set {
    name = "deployment.extraEnvs[0].name"
    value = "ELASTICSEARCH_PASSWORD"
  }

  set {
    name = "deployment.extraEnvs[0].value"
    value = "${var.context.elasticsearch.helm.authentication.password}"
  }

  set {
    name = "deployment.extraEnvs[1].name"
    value = "ELASTICSEARCH_USERNAME"
  }

  set {
    name = "deployment.extraEnvs[1].value"
    value = "${var.context.elasticsearch.helm.authentication.username}"
  }
}
