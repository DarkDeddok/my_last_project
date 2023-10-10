provider "helm" {
  version = "~> 1.3.2"
}

resource "helm_release" "redis" {
  name      = "${var.context.app_name}-redis"
  repository = "${var.context.mods.bitnami}"
  chart      = "redis"
  namespace = "${var.context.namespace}"
  version    = "17.3.1"
  recreate_pods = true
  wait       = "false"

  values = [
    "${file(".deploy/redis.values.yaml")}"
  ]

  set {
      name = "openiam.appname"
      value = "${var.context.app_name}"
  }

  set {
    name = "auth.password"
    value = "${var.context.redis.password}"
  }

  set {
    name = "global.redis.password"
    value = "${var.context.redis.password}"
  }

  set {
    name = "replica.replicaCount"
    value = "${var.context.redis.helm.replicas}"
  }

  set {
    name = "sentinel.enabled"
    value = "${var.context.redis.helm.sentinel.enabled}"
  }

  set {
    name = "sentinel.downAfterMilliseconds"
    value = "${var.context.redis.helm.sentinel.downAfterMilliseconds}"
  }

  set {
    name = "sentinel.failoverTimeout"
    value = "${var.context.redis.helm.sentinel.failoverTimeout}"
  }
}
