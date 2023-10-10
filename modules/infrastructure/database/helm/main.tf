provider "helm" {
  version = "~> 1.3.2"
}

resource "helm_release" "database" {
  name       = "${var.context.app_name}-${lower(var.context.database.type)}"
  repository = "${var.context.mods.bitnami}"
  chart      = "${lower(var.context.database.type) == "postgres" ? "postgresql" : "mariadb"}"
  version    = "${lower(var.context.database.type) == "postgres" ? "10.16.2" : "10.5.1"}"
  namespace = "${var.context.namespace}"
  recreate_pods = true
  wait       = "false"
  count      = "${length(var.context.database.helm.host) == 0  ? 1 : 0}"

  values = [
    "${file(".deploy/${lower(var.context.database.type) == "postgres" ? "postgresql" : "mariadb"}.values.yaml")}"
  ]

  set {
      name = "openiam.appname"
      value = "${var.context.app_name}"
  }

  # both
  set {
    name = "openiam.bash.log.level"
    value = "${var.context.logging.level.bash}"
  }

  # postgresql section
  set {
    name = "replication.enabled"
    value = "true"
  }
  set {
    name = "replication.readReplicas"
    value = "${var.context.database.helm.replicas}"
  }

  set {
    name = "postgresqlPassword"
    value = "${var.context.database.root.password}"
  }

  set {
    name = "postgresqlMaxConnections"
    value = "${35*(var.context.replica_count_map.esb + var.context.replica_count_map.workflow + var.context.replica_count_map.authmanager)}"
  }

  set {
    name = "persistence.size"
    value = "${var.context.database.helm.size}"
  }

  # mariadb section
  set {
    name = "primary.extraFlags"
    value = "--max_connections=${35*(var.context.replica_count_map.esb + var.context.replica_count_map.workflow + var.context.replica_count_map.authmanager)}"
  }

  set {
    name = "auth.rootPassword"
    value = "${var.context.database.root.password}"
  }

  set {
    name = "auth.replicationPassword"
    value = "${var.context.database.root.password}"
  }

  set {
    name = "secondary.extraFlags"
    value = "--max_connections=${35*(var.context.replica_count_map.esb + var.context.replica_count_map.workflow + var.context.replica_count_map.authmanager)}"
  }

  set {
    name = "secondary.replicaCount"
    value = "${var.context.database.helm.replicas}"
  }

  set {
    name = "architecture"
    value = "replication"
  }

  set {
    name = "primary.persistence.size"
    value = "${var.context.database.helm.size}"
  }

  set {
    name = "secondary.persistence.size"
    value = "${var.context.database.helm.size}"
  }
}
