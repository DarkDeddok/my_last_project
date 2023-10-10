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

resource "helm_release" "openiam" {
  name      = "${var.context.app_name}"
  chart      = "./openiam"
  version    = "4.2.1.3"
  wait       = "false"
  namespace = "${var.context.namespace}"
  recreate_pods = true

  # do not try to start openiam if you're migrating vault from a pre-4.2.1 release to 4.2.1+
  # the admin (deployer) will have to set this flag to `false`, in order to deploy OPENIAM
  # the next deployment (i.e. when this flag is `false`) should have vault running against an HA consul
  # backend
  count = "${var.context.vault.migrate == "true" ? 0 : 1}"

  # DO NOT SET THIS TO TRUE!!
  # doing so will result in DNS lookups failing in all subsequent pods that come up
  force_update  = false

    values = [
      "${file(".deploy/openiam.values.yaml")}"
    ]

    set {
        name = "openiam.appname"
        value = "${var.context.app_name}"
    }

    set {
      name = "openiam.vault.migrate"
      value = "${var.context.vault.migrate}"
    }

    set {
        name = "openiam.database.jdbc.openiam.host"
        value = "${var.database.host}"
    }

    set {
        name = "openiam.database.jdbc.openiam.port"
        value = "${var.database.port}"
    }

    set {
        name = "openiam.database.jdbc.activiti.host"
        value = "${var.database.host}"
    }

    set {
        name = "openiam.database.jdbc.activiti.port"
        value = "${var.database.port}"
    }

    set {
        name = "openiam.vault.url"
        value = "${var.vault.host}"
    }

    set {
        name = "openiam.redis.host"
        value = "${var.redis.host}"
    }

    set {
        name = "openiam.redis.port"
        value = "${var.redis.port}"
    }

    set {
        name = "openiam.redis.mode"
        value = "${var.redis.mode}"
    }

    set {
      name = "openiam.cloud_provider"
      value = "${var.cloud_provider}"
    }

    set {
        name = "openiam.database.type"
        value = "${var.context.database.type}"
    }

    set {
        name = "openiam.database.jdbc.openiam.databaseName"
        value = "${var.context.database.openiam.database_name}"
    }

    set {
        name = "openiam.database.jdbc.openiam.schemaName"
        value = "${var.context.database.openiam.schema_name}"
    }

    set {
        name = "openiam.database.jdbc.activiti.databaseName"
        value = "${var.context.database.activiti.database_name}"
    }

    set {
        name = "openiam.database.jdbc.activiti.schemaName"
        value = "${var.context.database.activiti.schema_name}"
    }

    set {
        name = "openiam.ui.replicas"
        value = "${var.context.replica_count_map.ui}"
    }

    set {
        name = "openiam.esb.replicas"
        value = "${var.context.replica_count_map.esb}"
    }

    set {
        name = "openiam.idm.replicas"
        value = "${var.context.replica_count_map.idm}"
    }

    set {
        name = "openiam.synchronization.replicas"
        value = "${var.context.replica_count_map.synchronization}"
    }

    set {
        name = "openiam.groovy_manager.replicas"
        value = "${var.context.replica_count_map.groovy_manager}"
    }

    set {
        name = "openiam.business_rule_manager.replicas"
        value = "${var.context.replica_count_map.business_rule_manager}"
    }

    set {
        name = "openiam.workflow.replicas"
        value = "${var.context.replica_count_map.workflow}"
    }

    set {
        name = "openiam.reconciliation.replicas"
        value = "${var.context.replica_count_map.reconciliation}"
    }

    set {
        name = "openiam.authmanager.replicas"
        value = "${var.context.replica_count_map.authmanager}"
    }

    set {
        name = "openiam.emailmanager.replicas"
        value = "${var.context.replica_count_map.emailmanager}"
    }

    set {
        name = "openiam.devicemanager.replicas"
        value = "${var.context.replica_count_map.devicemanager}"
    }

    set {
        name = "openiam.sasmanager.replicas"
        value = "${var.context.replica_count_map.sasmanager}"
    }

    set {
        name = "openiam.connectors.ldap.replicas"
        value = "${var.context.replica_count_map.connectors.ldap}"
    }

    set {
        name = "openiam.connectors.google.replicas"
        value = "${var.context.replica_count_map.connectors.google}"
    }

    set {
        name = "openiam.connectors.salesforce.replicas"
        value = "${var.context.replica_count_map.connectors.salesforce}"
    }

    set {
        name = "openiam.connectors.aws.replicas"
        value = "${var.context.replica_count_map.connectors.aws}"
    }

    set {
        name = "openiam.connectors.freshdesk.replicas"
        value = "${var.context.replica_count_map.connectors.freshdesk}"
    }

    set {
        name = "openiam.connectors.linux.replicas"
        value = "${var.context.replica_count_map.connectors.linux}"
    }

    set {
        name = "openiam.connectors.oracle_ebs.replicas"
        value = "${var.context.replica_count_map.connectors.oracle_ebs}"
    }

    set {
        name = "openiam.connectors.oracle.replicas"
        value = "${var.context.replica_count_map.connectors.oracle}"
    }

    set {
        name = "openiam.connectors.scim.replicas"
        value = "${var.context.replica_count_map.connectors.scim}"
    }

    set {
        name = "openiam.connectors.script.replicas"
        value = "${var.context.replica_count_map.connectors.script}"
    }

    set {
        name = "openiam.connectors.http_source_adapter.replicas"
        value = "${var.context.replica_count_map.http_source_adapter}"
    }

    set {
        name = "openiam.database.jdbc.sid"
        value = "${var.context.database.oracle.sid}"
    }

    set {
        name = "openiam.database.jdbc.timezone"
        value = "${lower(var.context.database.type) == "oracle" ? "${var.context.database.oracle.timezone}" : ""}"
    }

    set {
        name = "openiam.database.jdbcIncludeSchemaInQueries"
        value = "${var.context.database.jdbcIncludeSchemaInQueries}"
    }

    set {
        name = "openiam.database.hibernateIncludeSchemaInQueries"
        value = "${var.context.database.hibernateIncludeSchemaInQueries}"
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
        name = "openiam.elasticsearch.helm.curate.days"
        value = "${var.context.elasticsearch.helm.curate.days}"
    }

    set {
        name = "openiam.elasticsearch.helm.curate.maxIndexDays"
        value = "${var.context.elasticsearch.helm.curate.maxIndexDays}"
    }

    set {
        name = "openiam.elasticsearch.helm.curate.sizeGB"
        value = "${var.context.elasticsearch.helm.curate.sizeGB}"
    }


    set {
        name = "openiam.elasticsearch.helm.index.days"
        value = "${var.context.elasticsearch.helm.index.days}"
    }

    set {
        name = "openiam.elasticsearch.helm.index.maxIndexDays"
        value = "${var.context.elasticsearch.helm.index.maxIndexDays}"
    }

    set {
        name = "openiam.elasticsearch.helm.index.sizeGB"
        value = "${var.context.elasticsearch.helm.index.sizeGB}"
    }

    set {
        name = "openiam.elasticsearch.helm.index.warnPhaseDays"
        value = "${var.context.elasticsearch.helm.index.warnPhaseDays}"
    }

    set {
        name = "openiam.elasticsearch.helm.index.coldPhaseDays"
        value = "${var.context.elasticsearch.helm.index.coldPhaseDays}"
    }

    set {
        name = "openiam.gremlin.host"
        value = "${var.gremlin.host}"
    }

    set {
        name = "openiam.gremlin.port"
        value = "${var.gremlin.port}"
    }

    set {
        name = "openiam.gremlin.ssl"
        value = "${var.cloud_provider == "aws" ? "true" : "false"}"
    }

    set {
        name = "openiam.gremlin.type"
        value = "${var.cloud_provider == "aws" ? "neptune" : "janusgraph"}"
    }

    set {
      name = "openiam.flyway.command"
      value = "${var.database.flywayCommand}"
    }

    set {
        name = "openiam.flyway.baselineVersion"
        value = "${var.database.flywayBaselineVersion}"
    }

    set {
        name = "openiam.flyway.root.database"
        value = "${var.database.created_database}"
    }

    set {
        name = "openiam.flyway.rds"
        value = "${var.cloud_provider == "aws" ? "true" : "false"}"
    }

    set {
        name = "openiam.database.jdbc.hibernate.dialect"
        value = "${lower(var.context.database.type) == "oracle" || lower(var.context.database.type) == "mssql" ? "${var.context.database.hibernate.dialect}" : ""}"
    }

    set {
        name = "openiam.rabbitmq.host"
        value = "${var.rabbitmq.host}"
    }

    set {
        name = "openiam.rabbitmq.port"
        value = "${var.context.rabbitmq.tls.enabled ? "5671" : "5672"}"
    }

    set {
        name = "openiam.rabbitmq.tls.enabled"
        value = "${var.context.rabbitmq.tls.enabled}"
    }

    set {
        name = "openiam.bash.log.level"
        value = "${var.context.logging.level.bash}"
    }

    set {
      name = "openiam.java.additional.args.global"
      value = "${var.context.javaOpts.global}"
    }

    set {
        name = "openiam.ui.javaOpts"
        value = "${var.context.javaOpts.ui} -Dorg.openiam.docker.ui.container.name=${var.context.app_name}-ui -Dkibana.full.url=${var.elasticsearch.kibana_full_url} -Drabbitmq.full.url=http://${var.rabbitmq.host}:15672 -Djdk.tls.client.protocols=TLSv1.2"
    }

    set {
        name = "openiam.esb.javaOpts"
        value = "${var.context.javaOpts.esb}"
    }

    set {
        name = "openiam.idm.javaOpts"
        value = "${var.context.javaOpts.idm}"
    }

    set {
        name = "openiam.synchronization.javaOpts"
        value = "${var.context.javaOpts.synchronization}"
    }

    set {
        name = "openiam.groovy_manager.javaOpts"
        value = "${var.context.javaOpts.groovy_manager}"
    }

    set {
        name = "openiam.business_rule_manager.javaOpts"
        value = "${var.context.javaOpts.business_rule_manager}"
    }

    set {
        name = "openiam.workflow.javaOpts"
        value = "${var.context.javaOpts.workflow}"
    }

    set {
        name = "openiam.authmanager.javaOpts"
        value = "${var.context.javaOpts.authmanager}"
    }

    set {
        name = "openiam.connectors.ldap.javaOpts"
        value = "${var.context.javaOpts.connectors.ldap}"
    }

    set {
        name = "openiam.connectors.script.javaOpts"
        value = "${var.context.javaOpts.connectors.script}"
    }

    set {
        name = "openiam.connectors.google.javaOpts"
        value = "${var.context.javaOpts.connectors.google}"
    }

    set {
        name = "openiam.connectors.salesforce.javaOpts"
        value = "${var.context.javaOpts.connectors.salesforce}"
    }

    set {
        name = "openiam.emailmanager.javaOpts"
        value = "${var.context.javaOpts.emailmanager}"
    }

    set {
        name = "openiam.devicemanager.javaOpts"
        value = "${var.context.javaOpts.devicemanager}"
    }

    set {
      name = "openiam.connectors.rexx.javaOpts"
      value = "${var.context.javaOpts.connectors.rexx}"
    }

    set {
      name = "openiam.connectors.jdbc.javaOpts"
      value = "${var.context.javaOpts.connectors.jdbc}"
    }

    set {
      name = "openiam.connectors.saps4hana.javaOpts"
      value = "${var.context.javaOpts.connectors.saps4hana}"
    }

    set {
      name = "openiam.connectors.freshservice.javaOpts"
      value = "${var.context.javaOpts.connectors.freshservice}"
    }

    set {
      name = "openiam.connectors.tableau.javaOpts"
      value = "${var.context.javaOpts.connectors.tableau}"
    }

    set {
      name = "openiam.connectors.oracle_idcs.javaOpts"
      value = "${var.context.javaOpts.connectors.oracle_idcs}"
    }

    set {
      name = "openiam.connectors.workday.javaOpts"
      value = "${var.context.javaOpts.connectors.workday}"
    }

    set {
      name = "openiam.connectors.adp.javaOpts"
      value = "${var.context.javaOpts.connectors.adp}"
    }

    set {
      name = "openiam.connectors.ipa.javaOpts"
      value = "${var.context.javaOpts.connectors.ipa}"
    }

    set {
      name = "openiam.connectors.box.javaOpts"
      value = "${var.context.javaOpts.connectors.box}"
    }

    set {
      name = "openiam.connectors.boomi.javaOpts"
      value = "${var.context.javaOpts.connectors.boomi}"
    }

    set {
      name = "openiam.connectors.lastpass.javaOpts"
      value = "${var.context.javaOpts.connectors.lastpass}"
    }

    set {
      name = "openiam.connectors.kronos.javaOpts"
      value = "${var.context.javaOpts.connectors.kronos}"
    }

    set {
      name = "openiam.connectors.thales.javaOpts"
      value = "${var.context.javaOpts.connectors.thales}"
    }

    set {
      name = "openiam.connectors.postgresql.javaOpts"
      value = "${var.context.javaOpts.connectors.postgresql}"
    }

    set {
        name = "openiam.mysql.debugclient.enabled"
        value = "${lower(var.context.database.type) == "mariadb" ? "${var.context.database.debugclient.enabled}" : "0"}"
        type = "string"
    }

    set {
        name = "openiam.postgresql.debugclient.enabled"
        value = "${lower(var.context.database.type) == "postgres" ? "${var.context.database.debugclient.enabled}" : "0"}"
        type = "string"
    }

    set {
        name = "openiam.redis.debugclient.enabled"
        value = "${var.context.redis.debugclient.enabled}"
        type = "string"
    }

    set {
        name = "openiam.autodeploy"
        value = "${var.context.autodeploy.openiam == true} ? ${uuid()} : null"
    }

    set {
      name = "openiam.connectors.rexx.replicas"
      value = "${var.context.replica_count_map.connectors.rexx}"
    }

    set {
      name = "openiam.connectors.jdbc.replicas"
      value = "${var.context.replica_count_map.connectors.jdbc}"
    }

    set {
      name = "openiam.connectors.saps4hana.replicas"
      value = "${var.context.replica_count_map.connectors.saps4hana}"
    }

    set {
      name = "openiam.connectors.freshservice.replicas"
      value = "${var.context.replica_count_map.connectors.freshservice}"
    }

    set {
      name = "openiam.connectors.tableau.replicas"
      value = "${var.context.replica_count_map.connectors.tableau}"
    }

    set {
      name = "openiam.connectors.oracle_idcs.replicas"
      value = "${var.context.replica_count_map.connectors.oracle_idcs}"
    }

    set {
      name = "openiam.connectors.workday.replicas"
      value = "${var.context.replica_count_map.connectors.workday}"
    }

    set {
      name = "openiam.connectors.adp.replicas"
      value = "${var.context.replica_count_map.connectors.adp}"
    }

    set {
      name = "openiam.connectors.ipa.replicas"
      value = "${var.context.replica_count_map.connectors.ipa}"
    }

    set {
      name = "openiam.connectors.box.replicas"
      value = "${var.context.replica_count_map.connectors.box}"
    }

    set {
      name = "openiam.connectors.boomi.replicas"
      value = "${var.context.replica_count_map.connectors.boomi}"
    }

    set {
      name = "openiam.connectors.lastpass.replicas"
      value = "${var.context.replica_count_map.connectors.lastpass}"
    }

    set {
      name = "openiam.connectors.kronos.replicas"
      value = "${var.context.replica_count_map.connectors.kronos}"
    }

    set {
      name = "openiam.connectors.thales.replicas"
      value = "${var.context.replica_count_map.connectors.thales}"
    }

    set {
      name = "openiam.connectors.postgresql.replicas"
      value = "${var.context.replica_count_map.connectors.postgresql}"
    }
}


resource "helm_release" "openiam-rproxy" {
    name      = "${var.context.app_name}-rproxy"
    chart      = "./openiam-rproxy"
    namespace = "${var.context.namespace}"
    version    = "4.2.1.3"
    recreate_pods = true
    wait       = "false"

    values = [
      "${file("./.deploy/openiam.rproxy.values.yaml")}"
    ]

    set {
        name = "openiam.appname"
        value = "${var.context.app_name}"
    }

    set {
        name = "openiam.ui.service.host"
        value = "${var.context.app_name}-ui"
    }

    set {
        name = "openiam.ui.service.port"
        value = "8080"
    }

    set {
        name = "openiam.esb.service.host"
        value = "${var.context.app_name}-esb"
    }

    set {
        name = "openiam.esb.service.port"
        value = "9080"
    }

    set {
        name = "openiam.bash.log.level"
        value = "${var.context.logging.level.bash}"
    }

    set {
        name = "openiam.rproxy.http"
        value = "${var.context.rproxy.https.disabled}"
        type = "string"
    }

    set {
        name = "openiam.rproxy.ssl.cipherSuite"
        value = "${var.context.rproxy.https.cipherSuite}"
    }

    set {
      name = "openiam.rproxy.loadBalancer.ip"
      value = "${var.context.rproxy.loadBalancer.ip}"
    }

    set {
        name = "openiam.rproxy.https.host"
        value = "${var.context.rproxy.https.host}"
    }

    set {
        name = "openiam.rproxy.defaultUri"
        value = "${var.context.rproxy.defaultUri}"
    }

    set {
        name = "openiam.rproxy.disableConfigure"
        value = "${var.context.rproxy.disableConfigure}"
    }

    set {
        name = "openiam.rproxy.verbose"
        value = "${var.context.rproxy.verbose}"
    }

    set {
        name = "openiam.rproxy.debug.base"
        value = "${var.context.rproxy.debug.base}"
    }

    set {
        name = "openiam.rproxy.debug.esb"
        value = "${var.context.rproxy.debug.esb}"
    }

    set {
        name = "openiam.rproxy.debug.auth"
        value = "${var.context.rproxy.debug.auth}"
    }

    set {
        name = "openiam.rproxy.ssl.chain"
        value = fileexists(".ssl/openiam.ssl.ca.crt") ? "openiam.ssl.ca.crt" : ""
    }

    set {
        name = "openiam.rproxy.ssl.ca"
        value = fileexists(".ssl/openiam.sslchain.crt") ? "openiam.sslchain.crt" : ""
    }

    set {
        name = "openiam.rproxy.ssl.cert"
        value = fileexists(".ssl/openiam.crt") ? "openiam.crt" : ""
    }

    set {
        name = "openiam.rproxy.ssl.certKey"
        value = fileexists(".ssl/openiam.key") ? "openiam.key" : ""
    }

    set {
        name = "openiam.rproxy.log.error"
        value = "${var.context.rproxy.log.error}"
    }

    set {
        name = "openiam.rproxy.log.access"
        value = "${var.context.rproxy.log.access}"
    }

    set {
        name = "openiam.rproxy.deflate"
        value = "${var.context.rproxy.deflate}"
    }

    set {
        name = "openiam.rproxy.csp"
        value = "${var.context.rproxy.csp}"
    }

    set {
        name = "openiam.rproxy.cors"
        value = "${var.context.rproxy.cors}"
    }

    set {
        name = "openiam.rproxy.apache.extra"
        value = "${var.context.rproxy.apache.extra}"
    }

    set {
        name = "openiam.rproxy.vhost.extra"
        value = "${var.context.rproxy.vhost.extra}"
    }

    set {
        name = "openiam.rproxy.replicas"
        value = "${var.context.replica_count_map.rproxy}"
    }

    set {
        name = "openiam.autodeploy.rproxy"
        value = "${var.context.autodeploy.rproxy == true} ? ${uuid()} : null"
    }

    set {
        name = "openiam.rproxy.aws.certificateManagerARN"
        value = "${var.cloud_provider == "aws" ? "${var.context.rproxy.aws.certificateManagerARN}" : ""}"
    }

    set {
      name = "openiam.cloud_provider"
      value = "${var.cloud_provider}"
    }

    set {
        name = "openiam.rproxy.proxyPassReverse"
        value = "${var.context.rproxy.proxyPassReverse}"
    }
}
