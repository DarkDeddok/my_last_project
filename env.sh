#!/usr/bin/env bash

export DOCKER_IMAGE_PREFIX="openiamdocker"
export DOCKER_REGISTRY="docker.io"
export DOCKER_REGISTRY_SEPARATOR="/"
#export DOCKER_IMAGE_PREFIX=""
#export DOCKER_REGISTRY="373610796317.dkr.ecr.us-west-2.amazonaws.com"
#export DOCKER_REGISTRY_SEPARATOR=""
#export DOCKERHUB_USERNAME=AWS
#export DOCKERHUB_PASSWORD=$(aws ecr get-login-password --region us-west-2)
export BUILD_ENVIRONMENT="dev"
export OPENIAM_VERSION_NUMBER="4.2.1.4"
export IMAGE_PULL_POLICY="Always"
export OPENIAM_BASH_LOG_LEVEL="warn"
export APP_NAME="test2021"
export OSS="" #set to `-oss` if you're running in AWS

export LOGGING_LEVEL="INFO"
if [ "${BUILD_ENVIRONMENT}" == "prod" ]; then
  LOGGING_LEVEL="WARN"
fi

# these are only used if TLS is enabled in RabbitMQ
export RABBITMQ_HOST=${APP_NAME}-rabbitmq

# used for elasticsearch certs
export ELASTICSEARCH_HOST="elasticsearch-master"
export ELASTICSEARCH_KEY_PASSWORD="passwd00"


set +e

if [ -z "$CIRCLECI" ] && [ -z "$GENERATING_CERT" ]; then
    while true; do
        result=$(cat terraform.tfvars | grep app_name | grep $APP_NAME)
        if [ ! -z "$result" ]; then
            break;
        fi
        echo "Waiting for app_name in terraform.tfvars to equal $APP_NAME"
        sleep 10
    done
fi
