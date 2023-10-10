# AWS Kubernetes Guide

Follow this guide to deploy OpenIAM in AWS

## Set up the environment

1. Configure the [AWS CLI Version ](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).  Use Version 2.0.30.
2. export the access and secret keys as environment variables.  The following [link](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) lists supported regions.

    ```
    cat ~/.bash_profile
    export AWS_REGION=us-west-2
    export AWS_ACCESS_KEY_ID=<ACCESS_KEY>
    export AWS_SECRET_KEY=<SECRET_KEY>
    export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_KEY}
    ```

3. Set the region variable in terraform.tfvars to [region that supports EKS](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/)
4. Set the AWS-specific variables in terraform.tfvars



| Variable Name                                    | Required                       | Default Value               |  Description   |
| ------------------------------------- | ------------------------------ | --------------------------- | ------------- |
| region                                           | Y                              |                             | The region to be deployed.  For example, us-west-2
| replica_count                                    | Y                              |                             | The total number of nodes to be created in the kubernetes cluster
| database.root.user                               | Y                              |                             | The root username to the database
| database.root.password                           | Y                              |                             | The root username to the database
| database.port                                    | Y                              |                             | Database port.
| elasticsearch.aws.instance_class                 | Y                              |                             | The instance class of the ES instance.  See https://aws.amazon.com/elasticsearch-service/pricing/
| elasticsearch.aws.ebs_enabled                    | Y                              |                             | Certain instance types (listed here:  https://aws.amazon.com/elasticsearch-service/pricing/) use ESB.  For these, you MUST set this flag to true.  If your instance class uses SSD, and not EBS, then you MUST set this flag to false
| elasticsearch.aws.ebs_volume_size                | Y                              |                             | The volume size of the EBS, in GB.  Only used if ebs_enabled is set to true
| redis.aws.instance_class                         | Y                              |                             | The instance class of the Redis instance.  See See https://aws.amazon.com/elasticache/pricing/
| database.aws.port                                | Y                              |                             | The port where the RDS instance will be run
| database.aws.engine                              | Y                              |                             | See the 'Engine' parameter for the API: https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
|                                                  |                                |                             | We support mariadb, postgres, oracle
|                                                  |                                |                             | We do NOT currently support MSSQL in AWS RDS
|                                                  |                                |                             | We do NOT support or oracle se or oracle-se1.  They have a maximum version of Oracle 11, which
|                                                  |                                |                             | is not compatible with our version of flyway.  Also NOTE - oracle-ee has NOT been tested due to licencing limitations.  Use at your own risk                                                                                            
|                                                  |                                |                             | Thus - the only version tested version of Oracle in AWS that we fully support is oracle-se2.  Use oracle-ee at your own risk
| database.aws.instance_class                      | N                              | mariadb - db.t2.medium      | highly recommended. Instance class for the database instance.
|                                                  |                                |    postgres - db.t2.medium  | See - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html - for a complete list.
|                                                  |                                |    oracle-ee - db.m5.large  | if not specified, we will use a sensible default value, based on the database engine.  However, it is recommended to set this manually
|                                                  |                                |    oracle-se2 - db.m5.large |  
| database.aws.multi_az                            | Y                              |                             | Is this a mult-az Deployment?  See https://aws.amazon.com/rds/details/multi-az/
| database.aws.parameters                          | Y                              |                             | any additional parameters passed to the database instance upon creation.  See https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html
| database.aws.allocated_storage                   | Y                              |                             | See the 'AllocatedStorage' parameter for the API:  https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
| database.aws.storage_type                        | Y                              |                             | See the 'StorageType' parameter for the API: https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
| database.aws.backup_retention_period             | N                              |                             | See the 'BackupRetentionPeriod' parameter for the API: https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
|                                                  |                                |                             | A value of '0' disables backups
|                                                  |                                |                             | A non-zero value will resulut in terraform destroy failing.  terraform destroy will attempt to
|                                                  |                                |                             | delete the option group, which is associated with a database snapshop (which cannot be deleted)
| kubernetes.aws.machine_type                      | Y                              |                             | Machine Type of EKS Cluster.  See https://aws.amazon.com/ec2/pricing/on-demand/.  Minimum is m4.xlarge

5. Finally, you will have to setup the AWSServiceRoleForAmazonElasticsearchService role-link for your account.  To do this automatically via terraform, run the following commands:

```
cd bootstrap/aws
terraform init
terraform apply -var "region=${AWS_REGION}" -auto-approve
```

If you get an error like below, you can safely ignore it.  This just means that the role-link has already been created:

```
Error creating service-linked role with name es.amazonaws.com: InvalidInput: Service role name AWSServiceRoleForAmazonElasticsearchService has been taken in this account, please try a different suffix
```

Note:  you only need to run this step once per AWS organization.  Any subsequent runs will result in the above error (again, which you can ignore).

## Metricbeat and FileBeat

Metricbeat and filebeat are not available in AWS, due to incompatabilities with the latest version of Elasticsearch SAAS in AWS

## Important Note about Deploying

If you ever need to delete a pod, *NEVER* delete a pod with the '--force' flag.  If you do, it will result in all DNS lookups from that pod failing.
This looks to be a bug in AWS EKS.

OK:

```
kubectl delete pod/<pod_name>
```

NOT OK:

```
kubectl delete pod/<pod_name> --force --grace-period=0
```

If, when redeploying, a pod continuously fails to come up, it's likely because DNS is not resolving from within that pod.  In order to fix this, simply delete the pod (again, do NOT use the --force tag!)


## IAM

By default, only the user who created the cluster has access to the EKS cluster.  That means that only that user can execute kubectl commands against that cluster.  To fix this, you should
modify the following file:

```
iam.auto.tfvars
```

There, you can add the necessary users and roles which should have access to this EKS cluster.

## Destroying

Due to a bug with terraform's helm provider in AWS, destroying the objects in AWS must be performed in several automated and manual steps.
In the below commands, replace ${region} with your region (i.e. us-west-2)

First, run these commands:

```
terraform state rm module.deployment.module.helm
terraform state rm module.deployment.module.openiam-app
terraform state rm module.deployment.module.kubernetes
```

Next, delete the associated Load Balancers (created by helm):
1) https://${region}.console.aws.amazon.com/ec2/v2/home?region=${region}#LoadBalancers:sort=loadBalancerName

Next, run the destroy command:
```
terraform destroy # enter 'yes' when asked to do so
```

Most likely, you will encounter the following error.

```
Error: Error deleting VPC: DependencyViolation: The vpc 'vpc-0ef7fda5d9d6cbc32' has dependencies and cannot be deleted.
	status code: 400, request id: 9abbe8ea-a647-4007-97a1-238aaa8371e8
```

This just means that you need to delete the VPC manually via the AWS Console.  All other resources have been cleaned up

Finally, you will have to delete terraform's state files:
```
rm -rf terraform.tfstate*
```


## Known Issues:

When running terraform apply, you may get this error:

```
Error: error creating IAM policy test2021-CSI: EntityAlreadyExists: A policy called test2021-CSI already exists. Duplicate names are not allowed.
	status code: 409, request id: 384473b0-2f1f-4a1f-a000-cbcb016e984a

  on modules/core/aws/main.tf line 134, in resource "aws_iam_policy" "eks_worknode_ebs_policy":
 134: resource "aws_iam_policy" "eks_worknode_ebs_policy" {
```

Simply delete the policy in the AWS UI, and re-run `terraform apply`, in this case.


## Update Notes


### Updating to 4.2.1.2

We've updated to a newer version of the Elasticsearch Driver (7.15).  Unfortunately, AWS only supports up to 7.10.
Thus, for 4.2.1.2, you must use an in-house version of Elasticsearch.

Follow the following steps:

1. run `terraform state rm module.deployment.module.elasticsearch`
2. run `kubectl edit secret secrets`, and add the following two secrets:
elasticsearchUserName: <base64 value of `elasticsearch.helm.authentication.username` in terraform.tfvars>
elasticsearchPassword: <base64 value of `elasticsearch.helm.authentication.password` in terraform.tfvars>



3. update the terraform project to `HEAD` of `RELEASE-4.2.1.2`.
4. Use the dev tag in `env.sh` and run `./setup.sh`
5. run `kubectl delete jobs --all`
6. run `terraform init`
7. run `terraform apply -auto-approve`

You'll have to manually delete Elasticsearch SAAS from the AWS console.



### Updating to 4.2.1.3

We've updated our Kubernetes version to 1.23

1. In `main.tf`, set the `cluster_version` to `1.21`
2. Follow the upgrade steps in the [main README](../../../README.md)
3. Run terraform apply
4. In `main.tf`, set the `cluster_version` to `1.22`
5. Run `terraform apply`
6. In `main.tf`, set the `cluster_version` to `1.23`
7. Run `terraform apply`
