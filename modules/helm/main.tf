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

resource "helm_release" "configmap" {
    name          = "${var.context.app_name}-configmap"
    chart         = "./openiam-configmap"
    version       = "4.2.1.3"
    recreate_pods = true
    namespace     = "${var.context.namespace}"
    wait          = "true"

    values = [
      "${file("./.deploy/openiam.configmap.values.yaml")}"
    ]

    # will force a redeploy
    set {
        name  = "openiam.bump.version"
        value = "4.2.1.3"
    }

    set {
        name  = "openiam.appname"
        value = "${var.context.app_name}"
    }

    set {
        name  = "openiam.database.jdbc.openiam.databaseName"
        value = "${var.context.database.openiam.database_name}"
    }

    set {
        name  = "openiam.database.jdbc.activiti.databaseName"
        value = "${var.context.database.activiti.database_name}"
    }

    set {
        name  = "openiam.cassandra.password"
        value = "${var.context.cassandra.password}"
    }

    set {
        name  = "openiam.vault.secrets.jdbc.openiam.username"
        value = "${var.context.database.openiam.user}"
    }

    set {
        name  = "openiam.vault.secrets.jdbc.activiti.username"
        value = "${var.context.database.activiti.user}"
    }

    set {
        name  = "openiam.vault.secrets.jdbc.openiam.password"
        value = "${var.context.database.openiam.password}"
    }

    set {
        name  = "openiam.vault.secrets.jdbc.activiti.password"
        value = "${var.context.database.activiti.password}"
    }

    set {
        name  = "openiam.vault.secrets.rabbitmq.username"
        value = "${var.context.rabbitmq.user}"
    }

    set {
        name  = "openiam.vault.secrets.rabbitmq.password"
        value = "${var.context.rabbitmq.password}"
    }

    set {
        name  = "openiam.vault.secrets.rabbitmq.jksKeyPassword"
        value = "${var.context.rabbitmq.jksKeyPassword}"
    }

    set {
        name  = "openiam.rproxy.http"
        value = "${var.context.rproxy.https.disabled}"
        type  = "string"
    }

    set {
        name  = "openiam.vault.secrets.redis.password"
        value = "${var.cloud_provider == "helm" ? "${var.context.redis.password}" : ""}"
    }

    set {
        name  = "openiam.cloud_provider"
        value = "${var.cloud_provider}"
    }

    set {
        name  = "openiam.vault.secrets.jdbc.root.user"
        value = "${var.context.database.root.user}"
    }

    set {
        name  = "openiam.vault.secrets.jdbc.root.password"
        value = "${var.context.database.root.password}"
    }

    set {
        name  = "openiam.flyway.openiam.username"
        value = "${var.context.database.openiam.user}"
    }

    set {
        name  = "openiam.flyway.activiti.username"
        value = "${var.context.database.activiti.user}"
    }

    set {
        name  = "openiam.flyway.openiam.password"
        value = "${var.context.database.openiam.password}"
    }

    set {
        name  = "openiam.flyway.activiti.password"
        value = "${var.context.database.activiti.password}"
    }

    set {
        name  = "openiam.vault.secrets.javaKeystorePassword"
        value = "${var.context.vault.secrets.javaKeystorePassword}"
    }

    set {
        name  = "openiam.vault.secrets.jks.password"
        value = "${var.context.vault.secrets.jks.password}"
    }

    set {
        name  = "openiam.vault.secrets.jks.keyPassword"
        value = "${var.context.vault.secrets.jks.keyPassword}"
    }

    set {
        name  = "openiam.vault.secrets.jks.cookieKeyPassword"
        value = "${var.context.vault.secrets.jks.cookieKeyPassword}"
    }

    set {
        name  = "openiam.vault.secrets.jks.commonKeyPassword"
        value = "${var.context.vault.secrets.jks.commonKeyPassword}"
    }

    set {
        name  = "openiam.vault.keypass"
        value = "${var.context.vault.vaultKeyPassword}"
    }

    set {
        name  = "openiam.rabbitmq.tls.enabled"
        value = "${var.context.rabbitmq.tls.enabled}"
    }

    set {
        name  = "openiam.vault.secrets.elasticsearch.username"
        value = "${var.context.elasticsearch.helm.authentication.username}"
    }

    set {
        name  = "openiam.vault.secrets.elasticsearch.password"
        value = "${var.context.elasticsearch.helm.authentication.password}"
    }

    set {
        name  = "AddedToForceConfigmapToBeRecreatedDueToElasticsearchAuth"
        value = "AddedToForceConfigmapToBeRecreatedDueToElasticsearchAuth"
    }
}

resource "helm_release" "pvc" {
    name          = "${var.context.app_name}-pvc"
    chart         = "./openiam-pvc"
    namespace     = "${var.context.namespace}"
    version       = "4.2.1.3"
    recreate_pods = true
    wait          = "false"
    values        = var.context.use_longhorn ? ["${file("./.deploy/longhorn.pvc.values.yaml")}"]:["${file("./.deploy/openiam.pvc.values.yaml")}"]
    # see OE-80 - this will force a helm install
    #             we added a new volume which is required

    # will force a redeploy
    set {
        name  = "openiam.bump.version"
        value = "4.2.1.3"
    }

    set {
      name  = "openiam.appname"
      value = "${var.context.app_name}"
    }
}


resource "helm_release" "stash" {
  name      = "${var.context.app_name}-stash"
  repository = "${var.context.mods.appscode}"
  chart      = "stash"
  count      = "${var.context.stash.enabled && fileexists("./.stash/license.txt") ? 1 : 0}"
  version    = "v2022.09.29"
  namespace = "${var.context.namespace}"
  recreate_pods = true
  wait          = "false"

  values = [
    "${file("./.deploy/stash.values.yaml")}"
  ]

  set {
    name  = "logLevel"
    value = "1"
  }

  set {
    name = "openiam.appname"
    value = "${var.context.app_name}"
  }

  set {
    name = "replicaCount"
    value = "${var.context.stash.replicas}"
  }

  set {
    name = "features.community"
    value = "${var.context.stash.community}"
  }

  set {
    name = "features.enterprise"
    value = "${!var.context.stash.community}"
  }

  set {
    name  = "global.license"
    value = "${fileexists("./.stash/license.txt") ? file("./.stash/license.txt") : ""}"
  }
}

resource "helm_release" "rabbitmq" {
  name          = "${var.context.app_name}-rabbitmq"
  repository    = "${var.context.mods.bitnami}"
  chart         = "rabbitmq"
  version       = "10.1.16"
  namespace     = "${var.context.namespace}"
  recreate_pods = true
  wait          = "false"

  values = [
    "${file(".deploy/rabbitmq.values.yaml")}"
  ]

  set {
    name  = "openiam.appname"
    value = "${var.context.app_name}"
  }

  set {
    name  = "replicaCount"
    value = "${var.context.replica_count_map.rabbitmq}"
  }

  set {
    name  = "auth.username"
    value = "${var.context.rabbitmq.user}"
  }

  set {
    name  = "auth.password"
    value = "${var.context.rabbitmq.password}"
  }

  set {
    name  = "auth.erlangCookie"
    value = "${var.context.rabbitmq.cookie_name}"
  }

  set {
    name  = "memoryHighWatermark.enabled"
    value = "true"
  }

  set {
    name  = "memoryHighWatermark.type"
    value = "absolute"
  }

  set {
    name  = "memoryHighWatermark.value"
    value = "${var.context.rabbitmq.memory.memoryHighWatermark}"
  }

  set {
    name  = "communityPlugins"
    value = "${var.context.mods.software_repo}/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/3.10.0/rabbitmq_delayed_message_exchange-3.10.0.ez"
  }

  set {
    name  = "extraPlugins"
    value = "rabbitmq_delayed_message_exchange"
  }

  set {
    name  = "loadDefinition.enabled"
    value = "true"
  }

  set {
    name  = "loadDefinition.existingSecret"
    value = "rabbitmq-load-definition"
  }

  set {
    name  = "extraEnvVars[0].name"
    value = "RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS"
  }

  set {
    name  = "extraEnvVars[0].value"
    value = "-rabbitmq_management path_prefix \"/rabbitmq\""
  }

  set {
    name  = "extraConfiguration"
    value = "load_definitions = /app/load_definition.json"
  }

  set {
    name  = "auth.tls.enabled"
    value = "${var.context.rabbitmq.tls.enabled}"
  }

  set {
    name  = "auth.tls.failIfNoPeerCert"
    value = "${var.context.rabbitmq.tls.failIfNoPeerCert}"
  }

  set {
    name  = "auth.tls.sslOptionsVerify"
    value = "${var.context.rabbitmq.tls.sslOptionsVerify}"
  }

  set {
    name  = "auth.tls.existingSecret"
    value = "rabbitmq-certificates"
  }

  set {
    name  = "resources.requests.memory"
    value = "${var.context.rabbitmq.memory.request}"
  }

  set {
    name  = "resources.limits.memory"
    value = "${var.context.rabbitmq.memory.limit}"
  }

  set {
    name  = "service.type"
    value = "${var.context.rabbitmq.serviceType}"
  }

  //creates an implicit dependency, so that rabbitmq comes up only after configmap secrets are created
  set {
    name  = "configmap.dependency.placeholder"
    value = "${helm_release.configmap.name}"
  }
}

resource "helm_release" "consul" {
  name          = "${var.context.app_name}-consul"
  repository    = "${var.context.mods.hashicorp}"
  chart         = "consul"
  version       = "0.48.0"
  namespace     = "${var.context.namespace}"
  recreate_pods = true
  wait          = "true"

  values = [
    "${file("./.deploy/consul.values.yaml")}"
  ]

  set {
    name  = "openiam.appname"
    value = "${var.context.app_name}"
  }

  set {
    name  = "fakedependency"
    value = "${helm_release.configmap.name}"
  }

  set {
    name  = "imagePullSecrets[0]"
    value = "globalpullsecret"
  }

  set {
    name  = "global.name"
    value = "consul"
  }

  set {
    name  = "global.gossipEncryption.secretName"
    value = "${var.context.vault.consul.gossipEncryption.secretName}"
  }

  set {
    name  = "global.gossipEncryption.secretKey"
    value = "${var.context.vault.consul.gossipEncryption.secretKey}"
  }

  set {
    name  = "server.replicas"
    value = "${var.context.vault.replicas}"
  }

  set {
    name  = "server.storage"
    value = "${var.context.vault.consul.storage}"
  }

  set {
    name  = "server.connect"
    value = "true"
  }

  set {
    name  = "client.grpc"
    value = "true"
  }
}

resource "helm_release" "vault" {
    name          = "${var.context.app_name}-vault"
    chart         = "./openiam-vault"
    version       = "4.2.1.3"
    recreate_pods = true
    namespace     = "${var.context.namespace}"
    wait          = "false"
    timeout       = 900000

    values = [
      "${file("./.deploy/openiam.vault.values.yaml")}"
    ]

    set {
      name  = "openiam.appname"
      value = "${var.context.app_name}"
    }

    set {
      name  = "fakedependency"
      value = "${helm_release.configmap.name}"
    }

    set {
      name  = "fakedependency2"
      value = "${helm_release.consul.name}"
    }

    set {
      name  = "openiam.vault.replicas"
      value = "${var.context.vault.replicas}"
    }

    set {
      name  = "openiam.vault.migrate"
      value = "${var.context.vault.migrate}"
    }

    set {
      name  = "openiam.consul.url"
      value = "consul-server"
    }

    set {
      name  = "openiam.consul.port"
      value = "8500"
    }

    set {
      name  = "openiam.bash.log.level"
      value = "${var.context.logging.level.bash}"
    }

    set {
      name  = "openiam.autodeploy.vault"
      value = "${var.context.autodeploy.vault == true} ? ${uuid()} : null"
    }

    set {
      name  = "openiam.vault.url"
      value = "${var.context.app_name}-vault"
    }

    set {
      name  = "openiam.vault.cert.country"
      value = "${var.context.vault.cert.country}"
    }

    set {
      name  = "openiam.vault.cert.state"
      value = "${var.context.vault.cert.state}"
    }

    set {
      name  = "openiam.vault.cert.locality"
      value = "${var.context.vault.cert.locality}"
    }

    set {
      name  = "openiam.vault.cert.organization"
      value = "${var.context.vault.cert.organization}"
    }

    set {
      name  = "openiam.vault.cert.organizationunit"
      value = "${var.context.vault.cert.organizationunit}"
    }
}
