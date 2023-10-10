#!/bin/bash

set -e
set -x

sudo apt-get install -y --no-install-recommends curl bash git wget unzip zip openssh-client

#jfrog
sudo curl -fL https://getcli.jfrog.io | sudo sh
sudo chmod a+x jfrog
sudo cp jfrog /usr/local/bin


# helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
