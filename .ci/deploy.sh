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
    jfrog rt u "${artifact}-${HELM_CHART_VERSION}.tgz" "helm-dev/${artifact}-${HELM_CHART_VERSION}.tgz" --url=${ARTIFACTORY_CONTEXT_URL} --user=${OPENIAM_ARTIFACTORY_USER} --password=${OPENIAM_ARTIFACTORY_PASSWORD} --quiet=true
done