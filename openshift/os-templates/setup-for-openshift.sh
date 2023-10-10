#!/usr/bin/env bash

#uncomment to debug this script.
#set -x

#Change this based on your requirements
BUILD_ENVIRONMENT="qa"
OPENIAM_VERSION_NUMBER="4.2.1.1"
OPENIAM_BASH_LOG_LEVEL="WARN"
APP_NAME="openiam-app"

# Change this by demand. Usually this is what you need.
DOCKER_IMAGE_PREFIX="openiamdocker"
DOCKER_REGISTRY="docker.io"
OPENIAM_DB_USERNAME="IAMUSER"
ACTIVITI_DB_USERNAME="ACTIVITI"
OPENIAM_DB_NAME="openiam"
ACTIVITI_DB_NAME="activiti"
IMAGE_PULL_POLICY="Always"

VAULT_KEYPASS="changeit"
#RPROXY
openiam_rproxy_http=0

#docker
DOCKER_REGISTRY="docker.io"
DOCKERHUB_USERNAME=$DOCKERHUB_USERNAME
DOCKERHUB_PASSWORD=$DOCKERHUB_PASSWORD

# This are only used if TLS is enabled in RabbitMQ
RABBITMQ_HOST=${APP_NAME}-rabbitmq


if [ -z "${DOCKERHUB_USERNAME}" ]; then
  echo -n "Enter Username to access Dockerhub: "
  read -r DOCKERHUB_USERNAME
fi

if [ -z "${DOCKERHUB_PASSWORD}" ]; then
  echo -n "Enter Password for user ${DOCKERHUB_USERNAME} to access Dockerhub: "
  read -s DOCKERHUB_PASSWORD
  echo ""
fi


rm -rf openshift/.deploy
mkdir -p openshift/.deploy

current_project=$(oc project)
echo $current_project

if [[ $current_project == Using* ]];
then
  #set values file for override default parameters
  echo "BUILD_ENVIRONMENT=$BUILD_ENVIRONMENT" >> openshift/.deploy/values.env
  echo "OPENIAM_VERSION_NUMBER=$OPENIAM_VERSION_NUMBER" >> openshift/.deploy/values.env
  echo "OPENIAM_BASH_LOG_LEVEL=$OPENIAM_BASH_LOG_LEVEL" >> openshift/.deploy/values.env
  echo "APP_NAME=$APP_NAME" >> openshift/.deploy/values.env
  echo "DOCKER_IMAGE_PREFIX=$DOCKER_IMAGE_PREFIX" >> openshift/.deploy/values.env
  echo "DOCKER_REGISTRY=$DOCKER_REGISTRY" >> openshift/.deploy/values.env
  echo "OPENIAM_DB_USERNAME=$OPENIAM_DB_USERNAME" >> openshift/.deploy/values.env
  echo "ACTIVITI_DB_USERNAME=$ACTIVITI_DB_USERNAME" >> openshift/.deploy/values.env
  echo "OPENIAM_DB_NAME=$OPENIAM_DB_NAME" >> openshift/.deploy/values.env
  echo "ACTIVITI_DB_NAME=$ACTIVITI_DB_NAME" >> openshift/.deploy/values.env
  echo "IMAGE_PULL_POLICY=$IMAGE_PULL_POLICY" >> openshift/.deploy/values.env
  echo "VAULT_KEYPASS=VAULT_KEYPASS" >> openshift/.deploy/values.env
  echo "RABBITMQ_HOST=$RABBITMQ_HOST" >> openshift/.deploy/values.env


  oc delete template openiam-template
  oc create -f openshift/template-config.yaml
  oc process -f openshift/template-config.yaml --param-file=openshift/.deploy/values.env | oc create -f -

  oc create secret generic secrets \
    --from-literal=openiamDatabaseUserName=$OPENIAM_DB_USERNAME \
    --from-literal=activitiDatabaseUserName=$ACTIVITI_DB_USERNAME \
    --from-literal=openiamDatabasePassword=$OPENIAM_DB_PASSWORD \
    --from-literal=activitiDatabasePassword=$ACTIVITI_DB_PASSWORD \
    --from-literal=rabbitmqUserName=$RABBITMQ_USERNAME \
    --from-literal=rabbitmqPassword=$RABBITMQ_PASSWORD \
    --from-literal=rabbitmqJksKeyPassword=$RABBIT_JKS_KEY_PASSWORD \
    --from-literal=databaseRootUserName=$DB_ROOT_USER \
    --from-literal=databaseRootPassword=$DB_ROOT_PASSWORD \
    --from-literal=redisPassword=$REDIS_PASSWORD \
    --from-literal=flywayOpeniamUserName=$OPENIAM_DB_USERNAME \
    --from-literal=flywayActivitiUserName=$ACTIVITI_DB_USERNAME \
    --from-literal=flywayOpeniamPassword=$OPENIAM_DB_PASSWORD \
    --from-literal=flywayActivitiPassword=$ACTIVITI_DB_PASSWORD \
    --from-literal=javaKeystorePassword=changeit \
    --from-literal=jksPassword=$JKS_PASSWORD \
    --from-literal=jksKeyPassword=$JKS_KEY_PASSWORD \
    --from-literal=jksCookieKeyPassword=$COOKIE_KEY_PASS \
    --from-literal=jksCommonKeyPassword=$COMMON_KEY_PASS \
    --from-literal=vaultKeyPassword=$VAULT_KEY_PASS \
    --from-literal=cassandraPassword=$CASSANDRA_PASSWORD

  oc create configmap vault-server-config \
    --from-file=vault.crt=.vault/vault.crt \
    --from-file=vault.key=.vault/vault.key \
    --from-file=vault.ca.key=.vault/vault.ca.key

  cat .vault/vault.jks  | base64 > .vault/b64.jks

  oc create configmap vault-client-config \
    --from-file=vault.jks=.vault/b64.jks

  if [ $openiam_rproxy_http == 1 ] ; then
    test -f .ssl/openiam.key && {
    oc create configmap rproxy-ssl-keys \
      --from-file=openiam.key=.ssl/openiam.key
    }

    oc create configmap rproxy-ssl-keys \
      --from-file=openiam.crt=.ssl/openiam.crt \
      --from-file=openiam.ssl.ca.crt=.ssl/openiam.ssl.ca.crt \
      --from-file=openiam.sslchain.crt=.ssl/openiam.sslchain.crt
  fi

  oc create -f openshift/configs/rabbitmq.definitions.yaml
  oc create -f openshift/configs/postgresql.initdbscripts.yaml
  oc create -f openshift/configs/mariadb.initdbscripts.yaml


  oc create configmap apache-extra-config \
    --from-file=extraVHost.conf=.apache/extraVHost.conf \
    --from-file=extraApache.conf=.apache/extraApache.conf

  oc create secret docker-registry globalpullsecret --docker-server=${DOCKER_REGISTRY} --docker-username=${DOCKERHUB_USERNAME} --docker-password=$DOCKERHUB_PASSWORD



  oc delete template template-openiam-app
  sleep 2
  oc create -f openshift/template-openiam-app.yaml
  oc process -f openshift/template-openiam-app.yaml --param-file=openshift/.deploy/values.env | oc create -f -



else
  echo "Please login by oc and select required project"
fi
