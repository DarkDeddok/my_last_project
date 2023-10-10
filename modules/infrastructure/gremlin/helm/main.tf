provider "helm" {
  version = "~> 1.3.2"
}

resource "helm_release" "cassandra" {
  name       = "${var.context.app_name}-cassandra"
  repository = "${var.context.mods.bitnami}"
  chart      = "cassandra"
  namespace = "${var.context.namespace}"
  version    = "9.2.5"
  recreate_pods = true
  wait       = "true"
  timeout    = 900000


  values = [
    "${file("./.deploy/cassandra.values.yaml")}"
  ]

  set {
    name = "persistence.size"
    value = "${var.context.cassandra.persistenceSize}"
  }

  set {
    name = "service.nodePorts.cql"
    value = "9042"
  }

  set {
    name = "dbUser.password"
    value = "${var.context.cassandra.password}"
  }

  set {
    name = "replicaCount"
    value = "${var.context.cassandra.replicas}"
  }


  set {
      name = "openiam.appname"
      value = "${var.context.app_name}"
  }
}

resource "helm_release" "gremlin" {
    name      = "${var.context.app_name}-gremlin"
    chart      = "./openiam-gremlin"
    version    = "4.2.1.3"
    namespace = "${var.context.namespace}"
    recreate_pods = true
    wait       = "false"
    timeout    = 900000
    depends_on = [
        "helm_release.cassandra"
    ]

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
          name = "openiam.backend.type"
          value = "cql"
    }

    set {
      name = "openiam.backend.host"
      value = "${var.context.app_name}-cassandra"
    }

    set {
      name = "openiam.backend.port"
      value = "9042"
    }

    set {
        name = "openiam.cloud_provider"
        value = "helm"
    }

    set {
        name = "openiam.gremlin.replicas"
        value = "${var.context.gremlin.helm.replicas}"
    }

    set {
        name = "openiam.gremlin.additionalJavaOpts"
        value = "${var.context.gremlin.additionalJavaOpts}"
    }

    set {
        name = "openiam.bash.log.level"
        value = "${var.context.logging.level.bash}"
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
