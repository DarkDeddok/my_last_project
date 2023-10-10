# Private Kubernetes Clusteer Guide

Follow this guide to deploy OpenIAM in a private Kubernetes Cluster


## Set up the environment

1. Make sure to point your kubectl config to the correct cluster.  
   See the [following](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) guide for more information on how to do that.

2. Set the Private-specific variables in terraform.tfvars


| Variable Name                         | Required                       | Default Value               |  Description   |
| ------------------------------------- | ------------------------------ | --------------------------- | ------------- |
| database.root.password                | Y                              |                             | The root username to the database
| database.helm.port                    | Y - if you are managing your   |                             | The database port.  Set *only* if you are managing your own database
|                                       |     own database               |                             |
|                                       | N - if you are using Openiam's |                             |
|                                       |     mariadb/postgres helm      |                             |
|                                       |     templates                  |                             |
| database.helm.host                    | Y - if you are managing your   |                             | The database host.  Set *only* if you are managing your own database
|                                       |     own database               |                             |
|                                       | N - if you are using Openiam's |                             |
|                                       |     mariadb/postgres helm      |                             |
|                                       |     templates                  |                             |
| database.helm.replicas                | Y                              | Number of replicas of mariadb or postgres database to use
| elasticsearch.helm.esJavaOpts         | Y                              | -Xmx1536m -Xms1536m         | ES Java Arguments
| elasticsearch.helm.replicas           | Y                              | 1                           | Number of Elasticsearch replicas
| elasticsearch.helm.storageSize      | N                                | 30Gi                        | The amount of storage allocated to the Elasticsearch PVC
| kibana.helm.replicas                  | Y                              | 1                           | Number of Kibana replicas
| kibana.helm.enabled                   | Y                              | "true"                      | If set to 'false', kibana will not deploy
| metricbeat.helm.replicas              | Y                              | 1                           | Number of Metricbeat replicas
| metricbeat.helm.enabled               | Y                              | "true"                      | If set to 'false', metricbeat will not deploy
| filebeat.helm.replicas                | Y                              | 1                           | Number of Filebeat replicas
| filebeat.helm.enabled                 | Y                              | "true"                      | If set to 'false', filebeat will not deploy
| gremlin.helm.replicas                 | Y                              | 1                           | Number of Janusgraph replicas
| gremlin.helm.zookeeperReplicas        | Y                              | 1                           | Number of Zookpeer replicas
| gremlin.helm.hbase.replicas           | Y                              | 1                           | Number of Hbase replicas


## Using a non-NFS and non-longhorn block storage system

Ensure that in your private kubernetes cluster, you have a block storage system installed, such as `longhorn`.  If you are deploying to AWS EKS, Google GKE, Azure, Own Rancher + Longhorn kubernetes cluster, this will already be built-into the kuberentes cluster, and you will not have to do anything.  However, for private kubernetes clusters, for using with another block storage system (not nfs, not longhorn), you will need to perform this step.

By default, OpenIAM deploys `nfs` as part of the kubernetes stack or uses longhorn (depends on which case you choose in `setup.sh` script).  This will not work if you have your own block storage system installed.  Below is an example of the steps necessary to take, when using `yourstorageclass`.  This can be extrapolated to use with another block storage system.

### Step 1

Edit openiam-pvc/values.yaml
```
nfs-server-provisioner:
   replicaCount: 0 # <--- add this line
   storageClass:
     create: false # <-- Change from "true" to "false" since we'll use Longhorn

[..]
# Replace all storageClass
   storageClass: 'nfs'
# by
   storageClass: 'yourstorageclass'
```

You will have to run `./setup.sh` after making these changes  and enter `3` in `Please enter your choice:` request.

## Destroying

Run the destroy command:
```
terraform destroy # enter 'yes' when asked to do so
```

Finally, you will have to delete terraform's state files:
```
rm -rf terraform.tfstate*
```

## Update Notes


### Updating to 4.2.1.2

We've upgraded Redis

1) Delete the result of: `helm list | grep redis`
2) Remove terraform module: `terraform state rm module.deployment.module.redis.helm_release.redis`
3) Delete any pvc in the response of: `kubectl get pvc | grep redis`


We've also removed hbase in favour of cassandra
1) Delete the result of: `helm list | grep hbase`
2) Remove terraform module: `terraform state rm module.deployment.module.gremlin.helm_release.hbase`
3) Delete any pvc in the response of: `kubectl get pvc | grep hbase`
