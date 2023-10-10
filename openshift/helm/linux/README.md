# Deploying OpenIAM to OpenShift (Using Helm)

This document describes how to install OpenIAM in a OpenShift (Using Helm).

## Set Docker environment variables

First, create an account on [Dockerhub](https://hub.docker.com/)

Then export the following environment variables:
```
export DOCKER_REGISTRY=docker.io
export DOCKERHUB_USERNAME=******
export DOCKERHUB_PASSWORD=******
```

Replacing them with their corresponding values

## Install Helm

1. Install helm **v3.3.4**

```
https://github.com/helm/helm/releases/tag/v3.3.4
```

For linux:
```
1) Download https://get.helm.sh/helm-v3.3.4-linux-amd64.tar.gz
2 Unpack it (tar -zxvf helm-v3.3.4-linux-amd64.tar.gz)
3) Find the helm binary in the unpacked directory, and move it to its desired destination (mv linux-amd64/helm /usr/local/bin/helm)
```


## OpenShift Version

We have tested our helm scripts with OpenShift cluster on Azure.


## Prerequisites

### 1) Vault

We use Vault in order to securely store secrets.  
Our applications use certificate based authentication in order to securely talk to Vault.
Our images will generate a self-signed certificate to be used for vault.  However, if you would like to use
your own certificate, you can do the following:

1) Get a public/private keypair from a valid CA Authority, and put the files in:
* .vault/vault.key - the private key
* .vault/vault.crt - the public key

2) Then, run the following command:
```
. env.sh
openssl pkcs12 -export -in .vault/vault.crt -inkey .vault/vault.key -out .vault/vault.jks -password pass:${VAULT_KEYPASS}
```

Also, put all of the resulting files in `openshift/openiam-configmap/.vault/`

i.e.
```
cp .vault/vault.key openshift/openiam-configmap/.vault/
cp .vault/vault.crt openshift/openiam-configmap/.vault/
cp .vault/vault.jks openshift/openiam-configmap/.vault/
```

### 2) SMTP Server

You will need to setup an SMTP server.
If you do not have a corporate SMTP server, there are numerous SMTP Cloud Servers which you can use.
Setting up SMTP is outside the scope of this document.

### 3) RabbitMQ TLS

You can optionally run RabbitMQ with TLS enabled.

#### Adding your own TLS Certificates to RabbitMQ

If you would like to use your own Certificates with RabbitMQ, you will need to get a public/private keypair from a valid CA authority, and generate a JKS file.
Please follow the instructions in the [RabbitMQ TLS README](kubernates-docker-configuration/.rabbitmq/README.md)

#### Generating a self-signed certificate

You can also generate a self-signed certificate by running
```
kubernates-docker-configuration/generate.rabbitmq.certs.sh
```

### 3) HTTPS certificates

When running in OpenShift, we expose port 80, and 443 if https is enabled.  Our apache httpd server listens to these ports.
To setup https, see our [SSL README](kubernates-docker-configuration/.ssl/README.md) for a list of required files.

### 4) Configure Extra VHost and Apache Configs

You can optionally add 'extra' vhost and apache configs.  To do that, simply modify the following files as needed:
a) .apache/extraVHost.conf
b) .apache/extraApache.conf

These files will be put in /usr/local/apache2/conf/add, in the rproxy pod


#### 5) Initialize and Setup



Run the setup script

```
./setup.sh
```

Need check the pids_limit in node. Openshift 4.x - has default limit 1024. But esb requaired at start ~ 1700. So you need extend limit to 2048+
Ask Open Shift administrator to set pids limits or run the script - which will create machineconfiguration for worker nodes. Wait while nodes will be updated.
```
./extend_pids.sh
```
In this script you can find a description (in comments) - how to check pids_limit. 

#### 6) Deploy

Before start deploy, check if StorageClasases not contain 'default' StorageClass. Need remove 'default' status from exist StorageClass.
```
.openshift/helm/setup-helm.sh
```


### Check deployments

```
oc get rc,services
```


### Confirming successful deployment

Confirm that all pods are up and running with the following command:

```
oc get pods
```
or 
```
kubectl get pods
```

Ensure that the READY column does not have any failed pods.  For example:

#### Example of running pod
```
test100-esb-0                         1/1     Running   0          2m3s
```

#### Example of failed pod
```
test100-esb-0                         0/1     CrashLoopBackOff   4          2m3s
```

### Debugging failed pods

If a certain pod fails, gather it's logs for analysis.

```
oc logs pods/<name_of_failed_pod>
```
or
```
kubectl logs pods/<name_of_failed_pod>
```


## Accessing your deployed instance

To access your deployed instance of OpenIAM, run the following command:

```
. env.sh
oc get "service/${APP_NAME}-rproxy"

```

The output of the above command will contain an EXTERNAL IP column, for example:

```
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP                                                              PORT(S)        AGE
test100-rproxy   LoadBalancer   172.20.27.78   a0375c89dd2ec11e98bca0648c64953f-439827441.us-west-2.elb.amazonaws.com   80:32468/TCP   3m57s
```

Curl the above URL:
```
curl -L "http://${EXTERNAL_IP_FROM_ABOVE}/webconsole"
```

You may want to add a CNAME alias for the above URL, to make it more human-readable.


#### get api url :
az aro show -g $RESOURCEGROUP -n $CLUSTER --query apiserverProfile.url -o tsv


### REQUIREMENTS : 

### pids_limit
```
[warning][os,thread] Failed to start thread - pthread_create failed (EAGAIN) for attributes: stacksize: 1024k, guardsize: 0k, detached.
....
nested exception is java.lang.OutOfMemoryError: unable to create native thread: possibly out of memory or process/resource limits reached
```

may be not enough pids_limit (Default is 1024 for Openshift 4).
Use extend_pids.sh (description in this file as comment)
after start - esb has about 1600 pids.

### Memory
#### Infrastructure
- Janusgraph with Hbase backend - 1024M
- Elasticseach - 2048M (in-house, part of stack)
- Redis - 1 master, 2 slaves.  Master memory: 1048M (in-house, part of stack)
- MariaDB - 1 master, 1 slave.  Master memory: 1048M (in-house, part of stack)
- RabbitMQ - 1024M (in-house, part of stack)
- Cassandra - 5Gi

#### Memory on a per-app basis was as follows:
- ESB - 1024M
- UI - 2048M
- IDM - 512M
- Synchronization - 512M
- Business Rule Manager: 512M
- Reconciliation - 512M
- Groovy Manager - 512M
- Workflow - 1024M
- Auth Management - 256M
- Email Manager - 256M
- Device Manager - 307M
- SAS Manager - 256M
- Reverse Proxy - 512M
- Connectors (not used) - 128M



