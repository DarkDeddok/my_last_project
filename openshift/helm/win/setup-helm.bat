@echo off

call env.bat

:: Set password variables from file
if not exist .deploy\GEN_PWD.txt (
	echo "Need generate passwords file before start setup-helm"
	pause
	exit 1
)
for /f "delims== tokens=1,2" %%G in (.deploy\GEN_PWD.txt) do SET %%G=%%H
echo "---------- Generate passwords : Done ----------"


::oc create -f .deploy\role-for-sc.yaml
::oc create -f .deploy\role-binding-for-sc.yaml
::oc policy add-role-to-user admin system:serviceaccount:kube-system:persistent-volume-binder -n %APP_NAME%


mkdir .deploy

::set no_proxy=*.lhtcloud.com
::set http_proxy=<proxy-config>
::set https_proxy=%http_proxy%

helm repo add openiam https://openiam.jfrog.io/artifactory/helm
helm repo update

::set http_proxy=
::set https_proxy=

echo "--------------------------------------------------------"
echo "--------------- Initialize new configmap ---------------"
helm status -o table %APP_NAME%-configmap > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
if /I "%helm_status: =%" equ "deployed" (
    echo "Config map %APP_NAME%-configmap has been already installed. Skip it"
) else (
	echo "Initialize new configmap %APP_NAME%-configmap"

	IF not defined  DOCKERHUB_USERNAME (
        set /p DOCKERHUB_USERNAME="DOCKERHUB_USERNAME: "
    )

	IF not defined DOCKERHUB_PASSWORD (
        set /p DOCKERHUB_PASSWORD="DOCKERHUB_PASSWORD: "
    )

	echo "Creating new Config Maps and Secrets %APP_NAME%-configmap"

	mkdir ..\..\..\openiam-configmap\.ssl
	mkdir ..\..\..\openiam-configmap\.apache
	copy ..\..\..\.ssl ..\..\..\openiam-configmap\.ssl
	copy ..\..\..\.apache ..\..\..\openiam-configmap\.apache


    helm upgrade --install "%APP_NAME%-configmap" ..\..\..\openiam-configmap ^
    --set openiam.database.jdbc.openiam.databaseName=%OPENIAM_DB_NAME% ^
    --set openiam.database.jdbc.activiti.databaseName=%ACTIVITI_DB_NAME% ^
    --set openiam.database.jdbc.openiam.schemaName=%OPENIAM_DB_NAME% ^
    --set openiam.database.jdbc.activiti.schemaName=%ACTIVITI_DB_NAME% ^
    --set openiam.vault.secrets.jdbc.openiam.username=%OPENIAM_DB_USERNAME% ^
    --set openiam.vault.secrets.jdbc.activiti.username=%ACTIVITI_DB_USERNAME% ^
    --set openiam.vault.secrets.jdbc.openiam.password=%OPENIAM_DB_PASSWORD% ^
    --set openiam.vault.secrets.jdbc.activiti.password=%ACTIVITI_DB_PASSWORD% ^
    --set openiam.vault.secrets.jdbc.root.user=root ^
    --set openiam.vault.secrets.jdbc.root.password=%DB_ROOT_PASSWORD% ^
    --set openiam.vault.secrets.redis.password=%REDIS_PASSWORD% ^
    --set openiam.vault.secrets.rabbitmq.password=%RABBITMQ_PASSWORD% ^
    --set openiam.flyway.openiam.username=%OPENIAM_DB_USERNAME% ^
    --set openiam.flyway.activiti.username=%ACTIVITI_DB_USERNAME% ^
    --set openiam.flyway.openiam.password=%OPENIAM_DB_PASSWORD% ^
    --set openiam.flyway.activiti.password=%ACTIVITI_DB_PASSWORD% ^
    --set openiam.vault.secrets.rabbitmq.username=%RABBITMQ_USERNAME% ^
    --set openiam.rproxy.http=0 ^
    --set openiam.vault.secrets.javaKeystorePassword=changeit ^
    --set openiam.vault.secrets.jks.password=%JKS_PASSWORD% ^
    --set openiam.vault.secrets.jks.keyPassword=%JKS_KEY_PASSWORD% ^
    --set openiam.vault.secrets.jks.cookieKeyPassword=%COOKIE_KEY_PASS% ^
    --set openiam.vault.secrets.jks.commonKeyPassword=%COMMON_KEY_PASS% ^
    --set openiam.vault.secrets.elasticsearch.username=%ELASTICSEARCH_USERNAME% ^
    --set openiam.vault.secrets.elasticsearch.password=%ELASTICSEARCH_PASSWORD% ^
    --set openiam.cassandra.password=%CASSANDRA_PASSWORD% ^
    --set openiam.vault.keypass=%VAULT_KEY_PASS% ^
    --set openiam.rabbitmq.tls.enabled=true ^
    --set openiam.vault.secrets.rabbitmq.jksKeyPassword=%RABBIT_JKS_KEY_PASSWORD% ^
    --set openiam.image.environment=%BUILD_ENVIRONMENT% ^
    --set openiam.image.pullPolicy=%IMAGE_PULL_POLICY% ^
    --set openiam.image.credentials.username=%DOCKERHUB_USERNAME% ^
    --set openiam.image.credentials.password=%DOCKERHUB_PASSWORD% ^
    --set openiam.image.credentials.registry=%DOCKER_REGISTRY%

)



helm status -o table %APP_NAME%-configmap > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
if /I "%helm_status: =%" equ "deployed" (
	echo "Config map %APP_NAME%-configmap initialized."
	echo "Please store the following password. You also can check the values from k8s secret."
	echo "Redis Password: %REDIS_PASSWORD%"
	echo "RabbitMQ Password: %RABBITMQ_PASSWORD%"
	echo "Database (MariaDB) Root password: %DB_ROOT_PASSWORD%"
	echo "Cassandra password: %CASSANDRA_PASSWORD%"
) else (
	echo "Can't continue because  %APP_NAME%-configmap can't be initialized."
	pause
	exit 1
)


:: GET DATA FROM SECRET UNCOMMENT IF WILL NEED NOT USE FILE WITH PASSWORDS OR REPEAT OF DEPLOY WITH EXIST CONFIGMAP AND DELETED FILE WITH PASSWORDS
  oc get secret secrets -o jsonpath="{.data.openiamDatabaseUserName}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P OPENIAM_DB_USERNAME=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.openiamDatabasePassword}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P OPENIAM_DB_PASSWORD=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.activitiDatabaseUserName}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P OPENIAM_ACTIVITI_USERNAME=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.activitiDatabasePassword}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P OPENIAM_ACTIVITI_PASSWORD=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.databaseRootPassword}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P DB_ROOT_PASSWORD=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.databaseRootUserName}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P DB_ROOT_USERNAME=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.rabbitmqPassword}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P RABBITMQ_PASSWORD=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.redisPassword}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P REDIS_PASSWORD=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.elasticsearchUserName}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P ELASTICSEARCH_USERNAME=<.deploy\dec_tmp.txt

  oc get secret secrets -o jsonpath="{.data.elasticsearchPassword}" > .deploy\enc_tmp.txt
  certutil -decode -f .deploy\enc_tmp.txt .deploy\dec_tmp.txt
  SET /P ELASTICSEARCH_PASSWORD=<.deploy\dec_tmp.txt

  del .deploy\enc_tmp.txt
  del .deploy\dec_tmp.txt

echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-pvc ---------------"

helm status -o table %APP_NAME%-pvc > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install  "%APP_NAME%-pvc" -f .deploy\openiam-pvc.values.yaml openiam-pvc


echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-redis ---------------"

helm status -o table %APP_NAME%-redis > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install "%APP_NAME%-redis" openiam/redis ^
            --version "%REDIS_CHART_VERSION%" ^
						-f .deploy\redis.values.yaml ^
						--set sentinel.downAfterMilliseconds="5000" ^
						--set sentinel.failoverTimeout="5000" ^
						--set sentinel.enabled="true" ^
						--set auth.password="%REDIS_PASSWORD%" ^
						--set global.redis.password="%REDIS_PASSWORD%"


echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-cassandra ---------------"
helm status -o table %APP_NAME%-cassandra > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install "%APP_NAME%-cassandra" openiam/cassandra ^
  -f .deploy\cassandra.values.yaml ^
  --version  "%CASSANDRA_CHART_VERSION%" ^
  --set persistence.size=5Gi ^
  --set service.nodePorts.cql=9042 ^
  --set dbUser.password="%CASSANDRA_PASSWORD%" ^
  --set cluster.replicaCount=%NUM_WORKER_NODES% ^
  --set volumePermissions.securityContext.runAsUser="auto" ^
  --set securityContext.enabled=false ^
  --set shmVolume.chmod.enabled=false ^
  --set containerSecurityContext.runAsUser=null ^
  --set podSecurityContext.fsGroup=null



echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-elasticsearch "--------------- "
helm status -o table %APP_NAME%-elasticsearch > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install "%APP_NAME%-elasticsearch" openiam/elasticsearch ^
  --version "%ELASTICSEARCH_CHART_VERSION%" ^
  --values .deploy\elasticsearch.values.yaml ^
  --set clusterHealthCheckParams="wait_for_status=yellow&timeout=10s" ^
  --set replicas=%NUM_WORKER_NODES% ^
  --set volumeClaimTemplate.resources.requests.storage=5Gi ^
  --set esJavaOpts="-Xmx1536m -Xms1536m" ^
  --set sysctlInitContainer.enabled=false


oc get secret globalpullsecret -o jsonpath="{.data.\.dockerconfigjson}" > .deploy\dec_tmp.txt
SET /P DOCKERHUB_CREDENTIALS_JSON=<.deploy\dec_tmp.txt

echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-gremlin "--------------- "
helm status -o table %APP_NAME%-gremlin > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install %APP_NAME%-gremlin ..\..\..\openiam-gremlin ^
  --values .deploy\openiam-gremlin.values.yaml ^
  --set openiam.appname=%APP_NAME% ^
  --set openiam.image.prefix=%DOCKER_IMAGE_PREFIX% ^
  --set openiam.image.environment=%BUILD_ENVIRONMENT% ^
  --set openiam.image.version=%OPENIAM_VERSION_NUMBER% ^
  --set openiam.image.pullPolicy=%IMAGE_PULL_POLICY% ^
  --set openiam.backend.type="cql" ^
  --set openiam.backend.host=%APP_NAME%-cassandra ^
  --set openiam.backend.port=9042 ^
  --set openiam.gremlin.additionalJavaOpts="-Xms512m -Xmx768m" ^
  --set openiam.cloud_provider="helm" ^
  --set openiam.elasticsearch.host=elasticsearch-master ^
  --set openiam.elasticsearch.port=9200 ^
  --set openiam.gremlin.replicas=%NUM_WORKER_NODES% ^
  --set openiam.image.credentialsJSON=%DOCKERHUB_CREDENTIALS_JSON% ^
  --set openiam.bash.log.level=%OPENIAM_BASH_LOG_LEVEL% ^
  --set openiam.elasticsearch.username=%ELASTICSEARCH_USERNAME% ^
  --set openiam.elasticsearch.password=%ELASTICSEARCH_PASSWORD%



echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-rabbitmq "--------------- "
helm status -o table %APP_NAME%-rabbitmq > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install %APP_NAME%-rabbitmq openiam/rabbitmq ^
  --values .deploy\rabbitmq.values.yaml ^
  --version "%RABBITMQ_CHART_VERSION%" ^
  --set replicaCount=%NUM_WORKER_NODES% ^
  --set auth.username=%RABBITMQ_USERNAME% ^
  --set auth.password=%RABBITMQ_PASSWORD% ^
  --set memoryHighWatermark.enabled="true" ^
  --set memoryHighWatermark.type="absolute" ^
  --set memoryHighWatermark.value="1843MB" ^
  --set auth.erlangCookie="openiamCoookie" ^
  --set communityPlugins="https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/3.10.0/rabbitmq_delayed_message_exchange-3.10.0.ez" ^
  --set extraPlugins="rabbitmq_delayed_message_exchange" ^
  --set loadDefinition.enabled="true" ^
  --set loadDefinition.existingSecret="rabbitmq-load-definition" ^
  --set extraEnvVars[0].name="RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS" ^
  --set extraEnvVars[0].value="-rabbitmq_management path_prefix \"/rabbitmq\"" ^
  --set extraConfiguration="load_definitions = /app/load_definition.json" ^
  --set resources.requests.memory="2048Mi" ^
  --set resources.limits.memory="2048Mi" ^
  --set service.type=ClusterIP ^
  --set auth.tls.sslOptionsVerify=verify_none ^
  --set auth.tls.failIfNoPeerCert=false ^
  --set auth.tls.enabled=false




echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-database "--------------- "
helm status -o table %APP_NAME%-database > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install %APP_NAME%-database openiam/mariadb ^
  -f .deploy\mariadb.values.yaml ^
  --version "%MARIADB_CHART_VERSION%" ^
  --set auth.rootPassword=%DB_ROOT_PASSWORD% ^
  --set initdbScriptsConfigMap="mariadb-initdbscripts" ^
  --set openiam.bash.log.level="warn"



echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-consul "--------------- "
helm status -o table %APP_NAME%-consul > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install "%APP_NAME%-consul" openiam/consul ^
  -f .deploy\consul.values.yaml ^
  --version "%CONSUL_CHART_VERSION%" ^
  --set global.name="%APP_NAME%-consul" ^
  --set server.replicas=%NUM_WORKER_NODES% ^
  --set server.storage=5Gi ^
  --set server.connect=true ^
  --set client.grpc=true ^
  --set global.openshift.enabled=true




echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-vault "--------------- "
helm status -o table %APP_NAME%-vault > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install %APP_NAME%-vault ..\..\..\openiam-vault ^
  --values .deploy\openiam-vault.values.yaml ^
  --set openiam.appname=%APP_NAME% ^
  --set openiam.image.prefix=%DOCKER_IMAGE_PREFIX% ^
  --set openiam.image.environment=%BUILD_ENVIRONMENT% ^
  --set openiam.image.version=%OPENIAM_VERSION_NUMBER% ^
  --set openiam.image.pullPolicy=%IMAGE_PULL_POLICY% ^
  --set openiam.image.credentialsJSON=%DOCKERHUB_CREDENTIALS_JSON% ^
  --set openiam.bash.log.level=%OPENIAM_BASH_LOG_LEVEL% ^
  --set openiam.vault.migrate=false ^
  --set openiam.vault.replicas="%NUM_WORKER_NODES%" ^
  --set openiam.vault.url="%APP_NAME%-vault" ^
  --set openiam.consul.url="%APP_NAME%-consul-server" ^
  --set openiam.consul.port=8500 ^
  --set openiam.vault.cert.country=US ^
  --set openiam.vault.cert.state=NY ^
  --set openiam.vault.cert.locality=NYC ^
  --set openiam.vault.cert.organization=OpenIAM ^
  --set openiam.vault.cert.organizationunit=DevOps


echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-openiam "--------------- "
helm status -o table %APP_NAME%-openiam > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install %APP_NAME%-openiam ..\..\..\openiam ^
     --values .deploy\openiam.values.yaml ^
     --set openiam.gremlin.host=%APP_NAME%-janusgraph ^
     --set openiam.gremlin.ssl="false" ^
     --set openiam.gremlin.type="janusgraph" ^
     --set openiam.cloud_provider="helm" ^
		 --set openiam.java.additional.args.global="-Dlogging.level.root=WARN -Dlogging.level.org.openiam=WARN  -Dlogging.level.org.elasticsearch.client=ERROR" ^
     --set openiam.ui.javaOpts="-Djdk.tls.client.protocols=TLSv1.2 -Dorg.openiam.docker.ui.container.name=%APP_NAME%-ui" ^
     --set openiam.esb.javaOpts="" ^
     --set openiam.idm.javaOpts="" ^
     --set openiam.synchronization.javaOpts="" ^
     --set openiam.groovy_manager.javaOpts="" ^
     --set openiam.business_rule_manager.javaOpts="" ^
     --set openiam.workflow.javaOpts="" ^
     --set openiam.authmanager.javaOpts="" ^
     --set openiam.connectors.ldap.javaOpts="" ^
     --set openiam.connectors.google.javaOpts="" ^
     --set openiam.connectors.salesforce.javaOpts="" ^
     --set openiam.connectors.rexx.javaOpts="" ^
     --set openiam.emailmanager.javaOpts="" ^
     --set openiam.devicemanager.javaOpts="" ^
     --set openiam.sasmanager.javaOpts="" ^
     --set openiam.connectors.jdbc.javaOpts="" ^
     --set openiam.connectors.saps4hana.javaOpts="" ^
     --set openiam.connectors.tableau.javaOpts="" ^
     --set openiam.bash.log.level=%OPENIAM_BASH_LOG_LEVEL% ^
     --set openiam.appname=%APP_NAME% ^
     --set openiam.image.environment=%BUILD_ENVIRONMENT% ^
     --set openiam.image.pullPolicy=%IMAGE_PULL_POLICY% ^
     --set openiam.image.prefix=%DOCKER_IMAGE_PREFIX% ^
     --set openiam.image.version=%OPENIAM_VERSION_NUMBER% ^
     --set openiam.image.credentialsJSON=%DOCKERHUB_CREDENTIALS_JSON% ^
     --set openiam.image.credentials.registry=%DOCKER_REGISTRY% ^
     --set openiam.database.jdbc.openiam.host=%APP_NAME%-database-mariadb ^
     --set openiam.database.jdbc.hibernate.dialect="org.hibernate.dialect.MySQLDialect" ^
     --set openiam.flyway.baselineVersion="2.3.0.0" ^
     --set openiam.flyway.command=%FLYWAY_COMMAND% ^
     --set openiam.database.jdbc.openiam.port=3306 ^
     --set openiam.database.jdbc.activiti.host=%APP_NAME%-database-mariadb ^
     --set openiam.database.jdbc.activiti.port=3306 ^
     --set openiam.vault.url=%APP_NAME%-vault ^
     --set openiam.vault.secrets.redis.password=%REDIS_PASSWORD% ^
     --set openiam.redis.host="%APP_NAME%-redis-headless" ^
     --set openiam.redis.port="26379" ^
     --set openiam.vault.secrets.jdbc.openiam.username=%OPENIAM_DB_USERNAME% ^
     --set openiam.vault.secrets.jdbc.openiam.password=%OPENIAM_DB_PASSWORD% ^
     --set openiam.vault.secrets.jdbc.activiti.username=%OPENIAM_ACTIVITI_USERNAME% ^
     --set openiam.vault.secrets.jdbc.activiti.password=%OPENIAM_ACTIVITI_PASSWORD% ^
     --set openiam.database.type="MariaDB" ^
     --set openiam.database.jdbc.openiam.databaseName=%OPENIAM_DB_NAME% ^
     --set openiam.database.jdbc.activiti.databaseName=%ACTIVITI_DB_NAME% ^
     --set openiam.database.jdbc.openiam.schemaName=%OPENIAM_DB_NAME% ^
     --set openiam.database.jdbc.activiti.schemaName=%ACTIVITI_DB_NAME% ^
     --set openiam.elasticsearch.helm.curate.days=7 ^
     --set openiam.elasticsearch.helm.curate.maxIndexDays=14 ^
     --set openiam.elasticsearch.helm.curate.sizeGB=2 ^
     --set openiam.postgresql.debugclient.enabled="0" ^
     --set openiam.business_rule_manager.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.ui.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.esb.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.reconciliation.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.idm.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.synchronization.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.groovy_manager.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.workflow.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.elasticsearch.host="elasticsearch-master" ^
     --set openiam.elasticsearch.port=9200 ^
     --set openiam.vault.secrets.jdbc.root.user=%DB_ROOT_USERNAME% ^
     --set openiam.vault.secrets.jdbc.root.password=%DB_ROOT_PASSWORD% ^
     --set openiam.flyway.openiam.username=%OPENIAM_DB_USERNAME% ^
     --set openiam.flyway.activiti.username=%OPENIAM_ACTIVITI_USERNAME% ^
     --set openiam.flyway.openiam.password=%OPENIAM_DB_PASSWORD% ^
     --set openiam.flyway.activiti.password=%OPENIAM_ACTIVITI_PASSWORD% ^
     --set openiam.rabbitmq.host="%APP_NAME%-rabbitmq" ^
     --set openiam.vault.secrets.rabbitmq.password=%RABBITMQ_PASSWORD% ^
     --set openiam.redis.debugclient.enabled=0 ^
     --set openiam.mysql.debugclient.enabled=0 ^
     --set-string openiam.rabbitmq.port=5672 ^
     --set openiam.vault.migrate=false ^
     --set openiam.rabbitmq.tls.enabled=false ^
     --set openiam.authmanager.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.emailmanager.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.devicemanager.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.sasmanager.replicas=0 ^
     --set openiam.connectors.ldap.replicas=0 ^
     --set openiam.connectors.google.replicas=0 ^
     --set openiam.connectors.salesforce.replicas=0 ^
     --set openiam.connectors.aws.replicas=0 ^
     --set openiam.connectors.freshdesk.replicas=0 ^
     --set openiam.connectors.linux.replicas="%NUM_WORKER_NODES%" ^
     --set openiam.connectors.oracle_ebs.replicas=0 ^
     --set openiam.connectors.oracle.replicas=0 ^
     --set openiam.connectors.scim.replicas=0 ^
     --set openiam.connectors.script.replicas=0 ^
	 	 --set openiam.redis.mode="sentinel" ^
     --set openiam.database.jdbc.sid="" ^
     --set openiam.database.jdbc.timezone="" ^
     --set openiam.database.jdbc.serviceName="" ^
     --set openiam.elasticsearch.helm.index.days="10" ^
     --set openiam.elasticsearch.helm.index.maxIndexDays="1" ^
     --set openiam.elasticsearch.helm.index.sizeGB="10" ^
     --set openiam.elasticsearch.helm.index.warnPhaseDays="2" ^
     --set openiam.elasticsearch.helm.index.coldPhaseDays="3"



echo "------------------------------------------------------"
echo "--------------- Setup %APP_NAME%-rproxy "--------------- "
helm status -o table %APP_NAME%-rproxy > .deploy\status.txt
set helm_status=not_deployed
for /f "delims=: tokens=1,2" %%G in (.deploy\status.txt) do (
	if /I "%%G" equ "STATUS" set helm_status=%%H
)
helm upgrade --install %APP_NAME%-rproxy ..\..\..\openiam-rproxy ^
  -f .deploy\openiam-rproxy.values.yaml ^
  --set openiam.bash.log.level=warn ^
  --set openiam.appname=%APP_NAME% ^
  --set openiam.rproxy.http=1 ^
  --set openiam.image.environment=%BUILD_ENVIRONMENT% ^
  --set openiam.image.pullPolicy=%IMAGE_PULL_POLICY% ^
  --set openiam.image.prefix=%DOCKER_IMAGE_PREFIX% ^
  --set openiam.image.version=%OPENIAM_VERSION_NUMBER% ^
  --set openiam.image.prefix=%DOCKER_IMAGE_PREFIX% ^
  --set openiam.image.registryPrefixSeparator=%DOCKER_REGISTRY_SEPARATOR% ^
  --set openiam.image.registry=%DOCKER_REGISTRY% ^
  --set openiam.image.credentials.registry=%DOCKER_REGISTRY% ^
  --set openiam.image.credentials.username=%DOCKERHUB_USERNAME% ^
  --set openiam.image.credentials.password=%DOCKERHUB_PASSWORD% ^
  --set openiam.image.credentialsJSON=%DOCKERHUB_CREDENTIALS_JSON% ^
  --set openiam.rproxy.defaultUri=/selfservice/ ^
  --set-string openiam.rproxy.disableConfigure=0 ^
  --set-string openiam.rproxy.deflate=6 ^
  --set-string openiam.rproxy.csp=0 ^
  --set-string openiam.rproxy.cors=1 ^
  --set-string openiam.rproxy.verbose=0 ^
  --set-string openiam.rproxy.debug.base=0 ^
  --set-string openiam.rproxy.debug.esb=0 ^
  --set-string openiam.rproxy.debug.auth=0 ^
  --set-string openiam.rproxy.replicas="%NUM_WORKER_NODES%" ^
  --set openiam.rproxy.ssl.cert=openiam.crt ^
  --set openiam.rproxy.ssl.certKey=openiam.key ^
  --set openiam.rproxy.https.host= ^
  --set openiam.rproxy.log.error= ^
  --set openiam.rproxy.log.access= ^
  --set openiam.ui.service.host=%APP_NAME%-ui ^
  --set openiam.ui.service.port=8080 ^
  --set openiam.esb.service.host=%APP_NAME%-esb ^
  --set openiam.esb.service.port=9080

oc expose svc/%APP_NAME%-rproxy



::ports
::for Dev purposes do this tho proxy port to you 127.0.0.1 localhost
::oc port-forward --namespace %APP_NAME% svc/%APP_NAME%-database-mariadb 3306 &
::oc port-forward --namespace %APP_NAME% svc/%APP_NAME%-vault 8200 &
::oc port-forward --namespace %APP_NAME% svc/%APP_NAME%-esb 9080 &
::oc port-forward --namespace %APP_NAME% svc/%APP_NAME%-redis-master 6379
