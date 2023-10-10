ARG OPENIAM_VERSION_NUMBER

FROM ubuntu:bionic-20210222
MAINTAINER "OpenIAM DEV Team(dev-team@openiam.com)"

ENV HELM_VERSION=3.3.4
ENV TERRAFORM_VERSION=0.12.21
ENV AWS_CLI_VERSION=2.0.30
ENV KUBECTL_VERSION=1.19.0

LABEL name="openiamdocker/terraform" \
      vendor="OpenIAM" \
      version="$OPENIAM_VERSION_NUMBER" \
      release="0" \
      summary="OpenIAM Terraform Distribution" \
      description="This container contains Terraform and Helm for building out our terraform stuff" \
      url="https://www.openiam.com" \
      run='docker run openiamdocker/terraform:$OPENIAM_VERSION_NUMBER'

ENV OPENIAM_VERSION_NUMBER=
ENV AWS_REGION=
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_KEY=
ENV AWS_SECRET_ACCESS_KEY=

RUN apt update
RUN apt-get install -y git wget curl tar unzip sudo vim gettext-base apt-transport-https ca-certificates \
    apt-transport-https ca-certificates gnupg

# Google Cloud API
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN sudo apt-get update && sudo apt-get install -y google-cloud-sdk

RUN wget "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
RUN tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
RUN sudo mv linux-amd64/helm /usr/local/bin/helm

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN sudo mv terraform /usr/local/bin/terraform

RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
RUN sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

COPY resources/*.sh /usr/local/bin/

# executing user has to be root b/c we need to do permissions operations
USER root
ENTRYPOINT ["docker-entrypoint.sh"]
