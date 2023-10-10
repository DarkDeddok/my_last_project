#!/usr/bin/env bash

#uncomment to debug this script.
#set -x

. set_env.sh

# Before start, need check / create configure for create dynamic azure file
#
#
#apiVersion: rbac.authorization.k8s.io/v1
#kind: Role
#metadata:
#  name: system:controller:persistent-volume-binder
#  namespace: <user's project name>
#rules:
#  - apiGroups: [""]
#    resources: ["secrets"]
#    verbs: ["create", "get", "delete"]
#
#
#apiVersion: rbac.authorization.k8s.io/v1
#kind: RoleBinding
#metadata:
#  name: system:controller:persistent-volume-binder
#  namespace: <user's project>
#roleRef:
#  apiGroup: rbac.authorization.k8s.io
#  kind: Role
#  name: system:controller:persistent-volume-binder
#subjects:
#- kind: ServiceAccount
#  name: persistent-volume-binder
#namespace: kube-system
#
#
#kind: StorageClass
#apiVersion: storage.k8s.io/v1
#metadata:
#  name: azurefile
#provisioner: kubernetes.io/azure-file
#mountOptions:
#  - dir_mode=0777
#  - file_mode=0777


oc new-project ${APP_NAME}

mkdir -p .deploy
#envsubst < custom-values/redis.values.yaml > .deploy/redis.values.yaml
envsubst < custom-values/role-for-sc.yaml > .deploy/role-for-sc.yaml
envsubst < custom-values/role-binding-for-sc.yaml > .deploy/role-binding-for-sc.yaml

#Add permitions for correct work with azurefile
oc create -f .deploy/role-for-sc.yaml
oc create -f .deploy/role-binding-for-sc.yaml
oc policy add-role-to-user admin system:serviceaccount:kube-system:persistent-volume-binder -n ${APP_NAME}

#create StorageClass for azurefile
oc create -f custom-values/sc.yaml

#oc adm policy add-scc-to-group privileged system:authenticated

#helm repo add stable https://charts.helm.sh/stable --force-update
#helm repo add bitnami https://charts.bitnami.com/bitnami
#helm repo add bigdata-gradiant https://gradiant.github.io/bigdata-charts/
#helm repo add hashicorp https://helm.releases.hashicorp.com
#helm repo add elastic https://helm.elastic.co
helm repo add openiam https://openiam.jfrog.io/artifactory/helm
helm repo update

echo "----- Initialize new configmap -----"
if helm get manifest "${APP_NAME}"-configmap > /dev/null; then
    echo "Config map ${APP_NAME}-configmap has been already installed. Skip it"
else
    echo "Initialize new configmap ${APP_NAME}-configmap"
    if [ -z "${DOCKERHUB_USERNAME}" ]; then
      echo -n "Enter Username to access Dockerhub: "
      read -r DOCKERHUB_USERNAME
    fi

    if [ -z "${DOCKERHUB_PASSWORD}" ]; then
      echo -n "Enter Password for user ${DOCKERHUB_USERNAME} to access Dockerhub: "
      read -s DOCKERHUB_PASSWORD
      echo ""
    fi
    echo "Creating new Config Maps and Secrets ${APP_NAME}-configmap"
    mkdir -p ../../../openiam-configmap/.ssl && mkdir -p ../../../openiam-configmap/.apache
    cp -r ../../../.ssl/* ../../../openiam-configmap/.ssl/ && cp -r ../../../.apache/* ../../../openiam-configmap/.apache/

    REDIS_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    RABBITMQ_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    DB_ROOT_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    JKS_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    JKS_KEY_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    COOKIE_KEY_PASS="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    COMMON_KEY_PASS="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    VAULT_KEY_PASS="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    RABBIT_JKS_KEY_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    OPENIAM_DB_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    ACTIVITI_DB_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    ELASTICSEARCH_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    CASSANDRA_PASSWORD=="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
    sleep 1
    RABBITMQ_USERNAME="openiam"


    helm install "${APP_NAME}"-configmap ../../../openiam-configmap \
    --set openiam.database.jdbc.openiam.databaseName="${OPENIAM_DB_NAME}" \
    --set openiam.database.jdbc.activiti.databaseName="${ACTIVITI_DB_NAME}" \
    --set openiam.database.jdbc.openiam.schemaName="${OPENIAM_DB_NAME}" \
    --set openiam.database.jdbc.activiti.schemaName="${ACTIVITI_DB_NAME}" \
    --set openiam.vault.secrets.jdbc.openiam.username="${OPENIAM_DB_USERNAME}" \
    --set openiam.vault.secrets.jdbc.activiti.username="${ACTIVITI_DB_USERNAME}" \
    --set openiam.vault.secrets.jdbc.openiam.password="${OPENIAM_DB_PASSWORD}" \
    --set openiam.vault.secrets.jdbc.activiti.password="${ACTIVITI_DB_PASSWORD}" \
    --set openiam.vault.secrets.jdbc.root.user=root \
    --set openiam.vault.secrets.jdbc.root.password="${DB_ROOT_PASSWORD}" \
    --set openiam.vault.secrets.redis.password="${REDIS_PASSWORD}" \
    --set openiam.vault.secrets.rabbitmq.password="${RABBITMQ_PASSWORD}" \
    --set openiam.flyway.openiam.username="${OPENIAM_DB_USERNAME}" \
    --set openiam.flyway.activiti.username="${ACTIVITI_DB_USERNAME}" \
    --set openiam.flyway.openiam.password="${OPENIAM_DB_PASSWORD}" \
    --set openiam.flyway.activiti.password="${ACTIVITI_DB_PASSWORD}" \
    --set openiam.vault.secrets.rabbitmq.username="${RABBITMQ_USERNAME}" \
    --set openiam.rproxy.http=0 \
    --set openiam.vault.secrets.javaKeystorePassword=changeit \
    --set openiam.vault.secrets.jks.password="${JKS_PASSWORD}" \
    --set openiam.vault.secrets.jks.keyPassword="${JKS_KEY_PASSWORD}" \
    --set openiam.vault.secrets.jks.cookieKeyPassword="${COOKIE_KEY_PASS}" \
    --set openiam.vault.secrets.jks.commonKeyPassword="${COMMON_KEY_PASS}" \
    --set openiam.vault.secrets.elasticsearch.username="${ELASTICSEARCH_USERNAME}" \
    --set openiam.vault.secrets.elasticsearch.password="${ELASTICSEARCH_PASSWORD}" \
    --set openiam.cassandra.password="${CASSANDRA_PASSWORD}" \
    --set openiam.vault.keypass="${VAULT_KEY_PASS}" \
    --set openiam.rabbitmq.tls.enabled=true \
    --set openiam.vault.secrets.rabbitmq.jksKeyPassword="${RABBIT_JKS_KEY_PASSWORD}" \
    --set openiam.image.environment="${BUILD_ENVIRONMENT}" \
    --set openiam.image.pullPolicy="${IMAGE_PULL_POLICY}" \
    --set openiam.image.credentials.username="${DOCKERHUB_USERNAME}" \
    --set openiam.image.credentials.password="${DOCKERHUB_PASSWORD}" \
    --set openiam.image.credentials.registry="${DOCKER_REGISTRY}"

    if test $? -eq 0; then
      echo "Config map ${APP_NAME}-configmap initialized."
      echo "Please store the following password. You also can check the values from k8s secret."
      echo "Redis Password: ${REDIS_PASSWORD}"
      echo "RabbitMQ Password: ${RABBITMQ_PASSWORD}"
      echo "Database (MariaDB) Root password: ${DB_ROOT_PASSWORD}"
    else
       echo "Can't continue because  ${APP_NAME}-configmap can't be initialized."
       exit 1
    fi
fi

echo "=========== Setup pvc for azure file system ${APP_NAME}-pvc =========== "
helm upgrade --install "${APP_NAME}-pvc" \
            --values ../../../.deploy/openiam.pvc.values.yaml \
            --values custom-values/pvc-value.yaml \
            ../../../openiam-pvc

echo "=========== Setup ${APP_NAME}-redis =========== "
REDIS_PASSWORD="$(kubectl get secret secrets -o jsonpath="{.data.redisPassword}" | base64 --decode)"
helm upgrade --install "${APP_NAME}"-redis openiam/redis \
  --version "${REDIS_CHART_VERSION}" \
  --values ../../../.deploy/redis.values.yaml \
  --set auth.password="${REDIS_PASSWORD}" \
  --set global.redis.password="${REDIS_PASSWORD}" \
  --set sentinel.downAfterMilliseconds="5000" \
  --set sentinel.failoverTimeout="5000" \
  --set sentinel.enabled="true" \
  --set volumePermissions.containerSecurityContext.runAsUser="auto" \
  --set master.podSecurityContext.fsGroup=null \
  --set master.containerSecurityContext.runAsUser=null \
  --set replica.podSecurityContext.fsGroup=null \
  --set replica.containerSecurityContext.runAsUser=null \
  --set sentinel.podSecurityContext.fsGroup=null \
  --set sentinel.containerSecurityContext.runAsUser=null

echo "=========== Setup ${APP_NAME}-cassandra =========== "
echo "Setup ${APP_NAME}-cassandra"
CASSANDRA_PASSWORD="$(kubectl get secret secrets -o jsonpath="{.data.cassandraPassword}" | base64 --decode)"

helm upgrade --install "${APP_NAME}-cassandra" openiam/cassandra \
  -f ../../../.deploy/cassandra.values.yaml \
  --version "${CASSANDRA_CHART_VERSION}" \
  --set persistence.size=5Gi \
  --set service.nodePorts.cql=9042 \
  --set dbUser.password="${CASSANDRA_PASSWORD}" \
  --set cluster.replicaCount="${NUM_WORKER_NODES}"  \
  --set volumePermissions.securityContext.runAsUser="auto" \
  --set securityContext.enabled=false \
  --set shmVolume.chmod.enabled=false \
  --set containerSecurityContext.runAsUser=null \
  --set podSecurityContext.fsGroup=null

#echo "=========== Setup ${APP_NAME}-hbase =========== "
#echo "Setup ${APP_NAME}-hbase"
#if helm get manifest "${APP_NAME}"-hbase > /dev/null; then
#   echo "${APP_NAME}-hbase found. Continue..."
#else
#  echo "${APP_NAME}-hbase not found. Installing"
#  helm install "${APP_NAME}-hbase" \
#        -f ../../../.deploy/hbase.values.yaml \
#        --set zookeeper.replicaCount="${NUM_WORKER_NODES}" \
#        --set hbase.regionServer.replicas="${NUM_WORKER_NODES}" \
#        ./hbase
#fi

echo "=========== Setup ${APP_NAME}-elasticsearch =========== "
helm upgrade --install "${APP_NAME}"-elasticsearch openiam/elasticsearch \
  --version "${ELASTICSEARCH_CHART_VERSION}" \
  --set clusterHealthCheckParams="wait_for_status=yellow&timeout=10s" \
  --set-string replicas="${NUM_WORKER_NODES}" \
  --set volumeClaimTemplate.resources.requests.storage=5Gi \
  --set esJavaOpts="-Xmx1536m -Xms1536m" \
  --set sysctlInitContainer.enabled=false \
  --set podSecurityContext.fsGroup=null \
  --set podSecurityContext.runAsUser=null \
  --set securityContext.runAsUser=null \
  --values ../../../.deploy/elasticsearch.values.yaml

DOCKERHUB_CREDENTIALS_JSON="$(kubectl get secret globalpullsecret -o jsonpath="{.data.\.dockerconfigjson}")"

echo "=========== Setup ${APP_NAME}-gremlin =========== "
helm upgrade --install "${APP_NAME}"-gremlin ../../../openiam-gremlin \
      -f ../../../.deploy/openiam.gremlin.values.yaml \
      --set openiam.appname="${APP_NAME}" \
      --set openiam.image.prefix="${DOCKER_IMAGE_PREFIX}" \
      --set openiam.image.environment="${BUILD_ENVIRONMENT}" \
      --set openiam.image.version="${OPENIAM_VERSION_NUMBER}" \
      --set openiam.image.pullPolicy="${IMAGE_PULL_POLICY}" \
      --set openiam.backend.type="cql" \
      --set openiam.backend.host="${APP_NAME}-cassandra" \
      --set openiam.backend.port=9042 \
      --set openiam.gremlin.additionalJavaOpts="-Xms512m -Xmx768m" \
      --set openiam.cloud_provider="helm" \
      --set openiam.elasticsearch.host=elasticsearch-master \
      --set openiam.elasticsearch.port=9200 \
      --set openiam.gremlin.replicas="${NUM_WORKER_NODES}" \
      --set openiam.image.credentialsJSON="${DOCKERHUB_CREDENTIALS_JSON}" \
      --set openiam.bash.log.level="${OPENIAM_BASH_LOG_LEVEL}" \
      --set openiam.elasticsearch.username="${ELASTICSEARCH_USERNAME}" \
      --set openiam.elasticsearch.password="${ELASTICSEARCH_PASSWORD}"

echo "===========  Setup ${APP_NAME}-rabbitmq =========== "
RABBITMQ_PASSWORD="$(kubectl get secret secrets -o jsonpath="{.data.rabbitmqPassword}" | base64 --decode)"
helm upgrade --install "${APP_NAME}-rabbitmq" openiam/rabbitmq \
  --version "${RABBITMQ_CHART_VERSION}" \
  -f ../../../.deploy/rabbitmq.values.yaml \
  --set replicaCount="${NUM_WORKER_NODES}" \
  --set auth.username="${RABBITMQ_USERNAME}" \
  --set auth.password="${RABBITMQ_PASSWORD}" \
  --set memoryHighWatermark.enabled="true" \
  --set memoryHighWatermark.type="absolute" \
  --set memoryHighWatermark.value="1843MB" \
  --set auth.erlangCookie="openiamCoookie" \
  --set communityPlugins="https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/3.10.0/rabbitmq_delayed_message_exchange-3.10.0.ez" \
  --set extraPlugins="rabbitmq_delayed_message_exchange" \
  --set loadDefinition.enabled="true" \
  --set loadDefinition.existingSecret="rabbitmq-load-definition" \
  --set extraEnvVars[0].name="RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS" \
  --set extraEnvVars[0].value="-rabbitmq_management path_prefix \"/rabbitmq\"" \
  --set extraConfiguration="load_definitions = /app/load_definition.json" \
  --set resources.requests.memory="2048Mi" \
  --set resources.limits.memory="2048Mi" \
  --set service.type=ClusterIP \
  --set auth.tls.sslOptionsVerify=verify_none \
  --set auth.tls.failIfNoPeerCert=false \
  --set auth.tls.enabled=false \
  --set podSecurityContext.fsGroup=null \
  --set containerSecurityContext.runAsUser=null


echo "===========  Setup ${APP_NAME}-database =========== "
DB_ROOT_PASSWORD="$(kubectl get secret secrets -o jsonpath="{.data.databaseRootPassword}" | base64 --decode)"
helm upgrade --install "${APP_NAME}-database" openiam/mariadb  \
  -f ../../../.deploy/mariadb.values.yaml \
  --version "${MARIADB_CHART_VERSION}" \
  --set auth.rootPassword="${DB_ROOT_PASSWORD}" \
  --set initdbScriptsConfigMap="mariadb-initdbscripts" \
  --set openiam.bash.log.level="warn" \
  --set primary.containerSecurityContext.runAsUser=null \
  --set primary.podSecurityContext.fsGroup=null \
  --set secondary.containerSecurityContext.runAsUser=null \
  --set secondary.podSecurityContext.fsGroup=null

echo "===========  Setup Consul as ${APP_NAME}-consul =========== "
helm upgrade --install "${APP_NAME}-consul" openiam/consul \
  --version "${CONSUL_CHART_VERSION}" \
  -f ../../../.deploy/consul.values.yaml \
  --set global.name="${APP_NAME}-consul" \
  --set server.replicas="7" \
  --set server.storage=5Gi \
  --set server.connect=true \
  --set client.grpc=true \
  --set global.openshift.enabled=true


echo "===========  Setup Vault as ${APP_NAME}-vault =========== "
helm upgrade --install "${APP_NAME}-vault" ../../../openiam-vault \
  -f ../../../.deploy/openiam.vault.values.yaml \
  --set openiam.appname="${APP_NAME}" \
  --set openiam.image.prefix="${DOCKER_IMAGE_PREFIX}" \
  --set openiam.image.environment="${BUILD_ENVIRONMENT}" \
  --set openiam.image.registryPrefixSeparator="${DOCKER_REGISTRY_SEPARATOR}" \
  --set openiam.image.registry="${DOCKER_REGISTRY}" \
  --set openiam.image.version="${OPENIAM_VERSION_NUMBER}" \
  --set openiam.image.pullPolicy="${IMAGE_PULL_POLICY}" \
  --set openiam.image.credentialsJSON="${DOCKERHUB_CREDENTIALS_JSON}" \
  --set openiam.bash.log.level="${OPENIAM_BASH_LOG_LEVEL}" \
  --set openiam.vault.migrate=false \
  --set openiam.vault.replicas="${NUM_WORKER_NODES}" \
  --set openiam.vault.url="${APP_NAME}-vault" \
  --set openiam.consul.url="${APP_NAME}-consul-server" \
  --set openiam.consul.port=8500 \
  --set openiam.vault.cert.country=US \
  --set openiam.vault.cert.state=NY \
  --set openiam.vault.cert.locality=NYC \
  --set openiam.vault.cert.organization=OpenIAM \
  --set openiam.vault.cert.organizationunit=DevOps \
  --set global.openshift=true

OPENIAM_DB_USERNAME="$(kubectl get secret secrets -o jsonpath="{.data.openiamDatabaseUserName}" | base64 --decode)"
OPENIAM_DB_PASSWORD="$(kubectl get secret secrets -o jsonpath="{.data.openiamDatabasePassword}" | base64 --decode)"

OPENIAM_ACTIVITI_USERNAME="$(kubectl get secret secrets -o jsonpath="{.data.activitiDatabaseUserName}" | base64 --decode)"
OPENIAM_ACTIVITI_PASSWORD="$(kubectl get secret secrets -o jsonpath="{.data.activitiDatabasePassword}" | base64 --decode)"
DB_ROOT_PASSWORD="$(kubectl get secret secrets -o jsonpath="{.data.databaseRootPassword}" | base64 --decode)"
DB_ROOT_USERNAME="$(kubectl get secret secrets -o jsonpath="{.data.databaseRootUserName}" | base64 --decode)"
RABBITMQ_PASSWORD="$(kubectl get secret secrets -o jsonpath="{.data.rabbitmqPassword}" | base64 --decode)"


echo "===========  Setup OpenIAM Core as ${APP_NAME}-openiam =========== "
helm upgrade --install "${APP_NAME}-openiam" ../../../openiam \
     -f ../../../.deploy/openiam.values.yaml \
     --values custom-values/openiam.values.yaml \
     --set openiam.gremlin.host="${APP_NAME}-janusgraph" \
     --set openiam.gremlin.ssl="false" \
     --set openiam.gremlin.type="janusgraph" \
     --set openiam.cloud_provider="helm" \
     --set openiam.java.additional.args.global="-Dlogging.level.root=WARN -Dlogging.level.org.openiam=WARN  -Dlogging.level.org.elasticsearch.client=ERROR" \
     --set openiam.ui.javaOpts="-Djdk.tls.client.protocols=TLSv1.2 -Dorg.openiam.docker.ui.container.name=${APP_NAME}-ui" \
     --set openiam.esb.javaOpts="" \
     --set openiam.idm.javaOpts="" \
     --set openiam.synchronization.javaOpts="" \
     --set openiam.groovy_manager.javaOpts="" \
     --set openiam.business_rule_manager.javaOpts="" \
     --set openiam.workflow.javaOpts="" \
     --set openiam.authmanager.javaOpts="" \
     --set openiam.connectors.ldap.javaOpts="" \
     --set openiam.connectors.google.javaOpts="" \
     --set openiam.connectors.salesforce.javaOpts="" \
     --set openiam.connectors.rexx.javaOpts="" \
     --set openiam.emailmanager.javaOpts="" \
     --set openiam.devicemanager.javaOpts="" \
     --set openiam.sasmanager.javaOpts="" \
     --set openiam.connectors.jdbc.javaOpts="" \
     --set openiam.connectors.saps4hana.javaOpts="" \
     --set openiam.connectors.tableau.javaOpts="" \
     --set openiam.bash.log.level="${OPENIAM_BASH_LOG_LEVEL}" \
     --set openiam.appname="${APP_NAME}" \
     --set openiam.image.environment="${BUILD_ENVIRONMENT}" \
     --set openiam.image.pullPolicy="${IMAGE_PULL_POLICY}" \
     --set openiam.image.prefix="${DOCKER_IMAGE_PREFIX}" \
     --set openiam.image.registryPrefixSeparator="${DOCKER_REGISTRY_SEPARATOR}" \
     --set openiam.image.registry="${DOCKER_REGISTRY}" \
     --set openiam.image.version="${OPENIAM_VERSION_NUMBER}" \
     --set openiam.image.credentialsJSON="${DOCKERHUB_CREDENTIALS_JSON}" \
     --set openiam.image.credentials.registry="${DOCKER_REGISTRY}" \
     --set openiam.database.jdbc.openiam.host="${APP_NAME}-database-mariadb" \
     --set openiam.database.jdbc.hibernate.dialect="org.hibernate.dialect.MySQLDialect" \
     --set openiam.flyway.baselineVersion="2.3.0.0" \
     --set openiam.flyway.command=${FLYWAY_COMMAND} \
     --set openiam.database.jdbc.openiam.port=3306 \
     --set openiam.database.jdbc.activiti.host="${APP_NAME}-database-mariadb" \
     --set openiam.database.jdbc.activiti.port=3306 \
     --set openiam.vault.url="${APP_NAME}-vault" \
     --set openiam.vault.secrets.redis.password="${REDIS_PASSWORD}" \
     --set openiam.redis.host="${APP_NAME}-redis-headless" \
     --set openiam.redis.port="26379" \
     --set openiam.vault.secrets.jdbc.openiam.username="${OPENIAM_DB_USERNAME}" \
     --set openiam.vault.secrets.jdbc.openiam.password="${OPENIAM_DB_PASSWORD}" \
     --set openiam.vault.secrets.jdbc.activiti.username="${OPENIAM_ACTIVITI_USERNAME}" \
     --set openiam.vault.secrets.jdbc.activiti.password="${OPENIAM_ACTIVITI_PASSWORD}" \
     --set openiam.database.type="MariaDB" \
     --set openiam.database.jdbc.openiam.databaseName="${OPENIAM_DB_NAME}" \
     --set openiam.database.jdbc.activiti.databaseName="${ACTIVITI_DB_NAME}" \
     --set openiam.database.jdbc.openiam.schemaName="${OPENIAM_DB_NAME}" \
     --set openiam.database.jdbc.activiti.schemaName="${ACTIVITI_DB_NAME}" \
     --set openiam.elasticsearch.helm.curate.days=7 \
     --set openiam.elasticsearch.helm.curate.maxIndexDays=14 \
     --set openiam.elasticsearch.helm.curate.sizeGB=2 \
     --set openiam.postgresql.debugclient.enabled="0" \
     --set openiam.ui.replicas="${NUM_WORKER_NODES}" \
     --set openiam.esb.replicas="${NUM_WORKER_NODES}" \
     --set openiam.reconciliation.replicas="${NUM_WORKER_NODES}" \
     --set openiam.idm.replicas="${NUM_WORKER_NODES}" \
     --set openiam.synchronization.replicas="${NUM_WORKER_NODES}" \
     --set openiam.groovy_manager.replicas="${NUM_WORKER_NODES}" \
     --set openiam.workflow.replicas="${NUM_WORKER_NODES}" \
     --set openiam.business_rule_manager.replicas="${NUM_WORKER_NODES}" \
     --set openiam.elasticsearch.host="elasticsearch-master" \
     --set openiam.elasticsearch.port=9200 \
     --set openiam.vault.secrets.jdbc.root.user="${DB_ROOT_USERNAME}" \
     --set openiam.vault.secrets.jdbc.root.password="${DB_ROOT_PASSWORD}" \
     --set openiam.flyway.openiam.username="${OPENIAM_DB_USERNAME}" \
     --set openiam.flyway.activiti.username="${OPENIAM_ACTIVITI_USERNAME}" \
     --set openiam.flyway.openiam.password="${OPENIAM_DB_PASSWORD}" \
     --set openiam.flyway.activiti.password="${OPENIAM_ACTIVITI_PASSWORD}" \
     --set openiam.rabbitmq.host="${APP_NAME}-rabbitmq" \
     --set openiam.vault.secrets.rabbitmq.password="${RABBITMQ_PASSWORD}" \
     --set openiam.redis.debugclient.enabled=0 \
     --set openiam.mysql.debugclient.enabled=0 \
     --set-string openiam.rabbitmq.port=5672 \
     --set openiam.vault.migrate=false \
     --set openiam.rabbitmq.tls.enabled=false \
     --set openiam.authmanager.replicas="${NUM_WORKER_NODES}" \
     --set openiam.emailmanager.replicas="${NUM_WORKER_NODES}" \
     --set openiam.devicemanager.replicas="${NUM_WORKER_NODES}" \
     --set openiam.sasmanager.replicas=0 \
     --set openiam.connectors.ldap.replicas="${NUM_WORKER_NODES}" \
     --set openiam.connectors.google.replicas=0 \
     --set openiam.connectors.salesforce.replicas=0 \
     --set openiam.connectors.aws.replicas=0 \
     --set openiam.connectors.freshdesk.replicas=0 \
     --set openiam.connectors.linux.replicas="${NUM_WORKER_NODES}" \
     --set openiam.connectors.oracle_ebs.replicas=0 \
     --set openiam.connectors.oracle.replicas=0 \
     --set openiam.connectors.scim.replicas=0 \
     --set openiam.connectors.script.replicas=0 \
     --set openiam.redis.mode="sentinel" \
     --set openiam.database.jdbc.sid="" \
     --set openiam.database.jdbc.timezone="" \
     --set openiam.database.jdbc.serviceName="" \
     --set openiam.elasticsearch.helm.index.days="10" \
     --set openiam.elasticsearch.helm.index.maxIndexDays="1" \
     --set openiam.elasticsearch.helm.index.sizeGB="10" \
     --set openiam.elasticsearch.helm.index.warnPhaseDays="2" \
     --set openiam.elasticsearch.helm.index.coldPhaseDays="3"


echo "===========  Setup Reverse Proxy =========== "
helm upgrade --install "${APP_NAME}-rproxy" ../../../openiam-rproxy \
  -f ../../../.deploy/openiam.rproxy.values.yaml \
  --set openiam.bash.log.level=warn \
  --set openiam.appname="${APP_NAME}" \
  --set openiam.rproxy.http=1 \
  --set openiam.image.environment="${BUILD_ENVIRONMENT}" \
  --set openiam.image.pullPolicy="${IMAGE_PULL_POLICY}" \
  --set openiam.image.prefix="${DOCKER_IMAGE_PREFIX}" \
  --set openiam.image.registryPrefixSeparator="${DOCKER_REGISTRY_SEPARATOR}" \
  --set openiam.image.registry="${DOCKER_REGISTRY}" \
  --set openiam.image.version="${OPENIAM_VERSION_NUMBER}" \
  --set openiam.image.credentialsJSON="${DOCKERHUB_CREDENTIALS_JSON}" \
  --set openiam.image.credentials.registry="${DOCKER_REGISTRY}" \
  --set openiam.rproxy.defaultUri=/selfservice/ \
  --set-string openiam.rproxy.disableConfigure=0 \
  --set-string openiam.rproxy.deflate=6 \
  --set-string openiam.rproxy.csp=0 \
  --set-string openiam.rproxy.cors=1 \
  --set-string openiam.rproxy.verbose=0 \
  --set-string openiam.rproxy.debug.base=0 \
  --set-string openiam.rproxy.debug.esb=0 \
  --set-string openiam.rproxy.debug.auth=0 \
  --set-string openiam.rproxy.replicas="${NUM_WORKER_NODES}" \
  --set openiam.rproxy.ssl.cert=openiam.crt \
  --set openiam.rproxy.ssl.certKey=openiam.key \
  --set openiam.rproxy.https.host= \
  --set openiam.rproxy.log.error= \
  --set openiam.rproxy.log.access= \
  --set openiam.ui.service.host="${APP_NAME}-ui" \
  --set openiam.ui.service.port=8080 \
  --set openiam.esb.service.host="${APP_NAME}-esb" \
  --set openiam.esb.service.port=9080


oc expose svc/${APP_NAME}-rproxy
