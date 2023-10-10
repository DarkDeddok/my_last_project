#!/usr/bin/env bash

#uncomment to debug this script.
#set -x

. set_env.sh

helm uninstall ${APP_NAME}-rproxy
helm uninstall ${APP_NAME}-openiam
helm uninstall ${APP_NAME}-vault
helm uninstall ${APP_NAME}-consul
helm uninstall ${APP_NAME}-database
helm uninstall ${APP_NAME}-rabbitmq
helm uninstall ${APP_NAME}-gremlin
helm uninstall ${APP_NAME}-elasticsearch
helm uninstall ${APP_NAME}-cassandra
helm uninstall ${APP_NAME}-hbase
helm uninstall ${APP_NAME}-redis
helm uninstall ${APP_NAME}-pvc
helm uninstall ${APP_NAME}-configmap


