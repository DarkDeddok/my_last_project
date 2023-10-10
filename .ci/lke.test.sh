#!/usr/bin/env bash

pip install  --user --upgrade pip
pip install  --user linode-cli --upgrade

export PATH="/home/circleci/.local/bin:$PATH"
#export LINODE_CLI_OBJ_ACCESS_KEY="${LINODE_TOKEN}"
export LINODE_CLI_TOKEN="${LINODE_TOKEN}"

clusterName="test-123"
clusterId=$(linode-cli lke clusters-list --json | jq "[ .[] | select (.label  | test(\"${clusterName}\") ) ]" | jq -r .[].id)


echo "Install Helm"

wget https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
tar -zxvf helm-v3.7.1-linux-amd64.tar.gz
mv linux-amd64/helm /home/circleci/.local/bin

chmod +x /home/circleci/.local/bin/helm

helm --version
#TODO - Add create cluster and deploy to newly created cluster
echo "install kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

mv kubectl  /home/circleci/.local/bin
chmod +x /home/circleci/.local/bin/kubectl

kubectl --version
mkdir -p /home/circleci/.kube/

linode-cli lke kubeconfig-view "${clusterId}" --json | jq -r .[].kubeconfig  | base64 -d > /home/circleci/.kube/config

kubectl get pods