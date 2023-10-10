#!/usr/bin/env bash

set -x
set -e

artifact_list=(
	openiam
	openiam-configmap
	openiam-gremlin
	openiam-pvc
	openiam-rproxy
	openiam-vault
)

for artifact in "${artifact_list[@]}"
do
    jfrog rt cp "helm-$1/${artifact}-${HELM_CHART_VERSION}.tgz" "helm-$2" \
          --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD}
done