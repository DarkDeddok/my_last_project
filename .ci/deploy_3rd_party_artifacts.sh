#!/usr/bin/env bash

set -x
set -e

sudo helm repo add stable https://charts.helm.sh/stable --force-update
sudo helm repo add bitnami https://charts.bitnami.com/bitnami
sudo helm repo add bigdata-gradiant https://gradiant.github.io/bigdata-charts/
sudo helm repo add hashicorp https://helm.releases.hashicorp.com
sudo helm repo add elasticsearch https://helm.elastic.co
sudo helm repo add appscode https://charts.appscode.com/stable
sudo helm repo add scylla https://scylla-operator-charts.storage.googleapis.com/stable
sudo helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner

sudo helm pull bitnami/redis --version ${REDIS_CHART_VERSION}
sudo helm pull bitnami/mariadb --version ${MARIADB_CHART_VERSION}
sudo helm pull bitnami/mariadb-galera --version ${MARIADB_GALERA_CHART_VERSION}
sudo helm pull bitnami/postgresql --version ${POSGRESQL_CHART_VERSION}
sudo helm pull bitnami/rabbitmq --version ${RABBITMQ_CHART_VERSION}
sudo helm pull bitnami/cassandra --version ${CASSANDRA_CHART_VERSION}
sudo helm pull hashicorp/consul --version ${CONSUL_CHART_VERSION}
sudo helm pull elasticsearch/elasticsearch --version ${ELASTICSEARCH_CHART_VERSION}
sudo helm pull elasticsearch/metricbeat --version ${ELASTICSEARCH_CHART_VERSION}
sudo helm pull elasticsearch/filebeat --version ${ELASTICSEARCH_CHART_VERSION}
sudo helm pull elasticsearch/kibana --version ${ELASTICSEARCH_CHART_VERSION}
sudo helm pull appscode/stash --version ${STASH_VERSION}
sudo helm pull nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner --version ${NFS_CHART_VERSION}

# stash doesn't work when we host the image in our dockerhub (due to a bug in stash)
# we try to fix it here by modifying the image tag
#tar -xvf "stash-${STASH_VERSION}.tgz"
#rm  -f "stash-${STASH_VERSION}.tgz"
#cd stash/templates
#sed 's/--docker-registry={{ .Values.operator.registry }}/--docker-registry={{ .Values.operator.registry }}{{ .Values.operator.runtimePrefix }}/g' deployment.yaml > deployment.yaml.2
#mv deployment.yaml.2 deployment.yaml
#cat deployment.yaml
#cd ../../
#tar -zcvf "stash-${STASH_VERSION}.tgz" stash

jfrog rt u "nfs-server-provisioner-${NFS_CHART_VERSION}.tgz" "helm-prod/nfs-server-provisioner-${NFS_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "cassandra-${CASSANDRA_CHART_VERSION}.tgz" "helm-prod/cassandra-${CASSANDRA_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "rabbitmq-${RABBITMQ_CHART_VERSION}.tgz" "helm-prod/rabbitmq-${RABBITMQ_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "redis-${REDIS_CHART_VERSION}.tgz" "helm-prod/redis-${REDIS_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "mariadb-${MARIADB_CHART_VERSION}.tgz" "helm-prod/mariadb-${MARIADB_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "mariadb-galera-${MARIADB_GALERA_CHART_VERSION}.tgz" "helm-prod/mariadb-galera-${MARIADB_GALERA_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "postgresql-${POSGRESQL_CHART_VERSION}.tgz" "helm-prod/postgresql-${POSGRESQL_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "consul-${CONSUL_CHART_VERSION}.tgz" "helm-prod/consul-${CONSUL_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "elasticsearch-${ELASTICSEARCH_CHART_VERSION}.tgz" "helm-prod/elasticsearch-${ELASTICSEARCH_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "metricbeat-${ELASTICSEARCH_CHART_VERSION}.tgz" "helm-prod/metricbeat-${ELASTICSEARCH_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "filebeat-${ELASTICSEARCH_CHART_VERSION}.tgz" "helm-prod/filebeat-${ELASTICSEARCH_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "kibana-${ELASTICSEARCH_CHART_VERSION}.tgz" "helm-prod/kibana-${ELASTICSEARCH_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
jfrog rt u "stash-${STASH_VERSION}.tgz" "helm-prod/stash-${STASH_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
