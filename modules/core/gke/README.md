# GKE Kubernetes Guide

Follow this guide to deploy OpenIAM in GKE


## Set up the environment

1. Authenticate into Google:

```
gcloud auth login
gcloud auth application-default login
```

2. Set the project, replace `YOUR_PROJECT` with your project ID:

    ```
    PROJECT=YOUR_PROJECT
    ```

    YOUR_PROJECT is the project ID, *not* the project name.  See [Google Cloud Documentation](https://cloud.google.com/resource-manager/docs/creating-managing-projects) for more on locating the Project ID in the Google Cloud Control Panel

    ```
    gcloud config set project ${PROJECT}
    ```

3. Configure the environment for Terraform:

    ```
    export GOOGLE_PROJECT=$(gcloud config get-value project)
    ```

4. Re-run `setup.sh` in the root of the project

5. Enable the Service Management API:

    ```
    gcloud services enable cloudbuild.googleapis.com
    gcloud services enable compute.googleapis.com
    gcloud services enable servicemanagement.googleapis.com
    gcloud services enable sql-component.googleapis.com
    gcloud services enable sqladmin.googleapis.com
    gcloud services enable redis.googleapis.com
    ```


6. Set the region variable in terraform.tfvars to [region that supports GKS](https://cloud.google.com/compute/docs/regions-zones/)

7. Some of our services, when running in GKE, require authentication into google cloud.  For this, we a Service Account File.  There are two ways to do this.  Specifically, *BigTable* requires this.
a) You can simply use your `gcloud` credential file, and run this:
```
    mkdir -p .google
    mkdir -p openiam-configmap/.google
    cp ~/.config/gcloud/application_default_credentials.json .google/gcloud.creds.json
    cp ~/.config/gcloud/application_default_credentials.json openiam-configmap/.google/gcloud.creds.json
```

b) Follow [these](https://cloud.google.com/docs/authentication/production#command-line) steps.
   You will have to make sure that the result json file is in `.google/gcloud.creds.json`

8. Set the GKE-specific variables in terraform.tfvars


| Variable Name                         | Required                       | Default Value               |  Description   |
| ------------------------------------- | ------------------------------ | --------------------------- | ------------- |
| region                                | Y                              |                             | The region to be deployed.  For example, us-west2
| replica_count                         | Y                              |                             | The total number of nodes to be created in the kubernetes cluster
| database.root.user                    | Y                              |                             | The root username to the database
| database.root.password                | Y                              |                             | The root username to the database
| redis.google.memory                   | Y                              |                             | Memory of the Redis instance (in GB)
| database.google.instance_class        | N                              |                             | Google Instance class for the database instance.
|                                       |                                |                             | For Mysql, see https://cloud.google.com/sql/pricing#2nd-gen-pricing
|                                       |                                |                             | For Postgres, see https://cloud.google.com/sql/pricing#pg-pricing
|                                       |                                |                             | Note - for Postgres, using any of the provided tiers will NOT be enough, due to limitations to the number of concurrent connections
|                                       |                                |                             |        see - https://cloud.google.com/sql/docs/postgres/quotas
|                                       |                                |                             | If you're using Postgres, you will have to create a custom tier, and then use that as the value of this string.  See https://cloud.google.com/compute/docs/instances/creating-instance-with-custom-machine-type#create
| kubernetes.gke.machine_type           | Y                              |                             | Machine Type of GKE Cluster.  See https://cloud.google.com/compute/docs/machine-types.  Minimum is n1-standard-4
| elasticsearch.helm.esJavaOpts         | Y                              | -Xmx1536m -Xms1536m         | ES Java Arguments
| elasticsearch.helm.replicas           | Y                              | 1                           | Number of replicas

## Destroying

Due to a bug with terraform's helm provider in GKE, destroying the objects in GKE must be performed in several automated and manual steps.

First, run these commands:

```
terraform state rm module.deployment.module.helm
terraform state rm module.deployment.module.openiam-app
terraform state rm module.deployment.module.kubernetes
terraform state rm module.deployment.module.elasticsearch
terraform state rm module.deployment.module.monitoring
terraform state rm module.deployment.module.kibana
```

Next, run the destroy command:
```
terraform destroy # enter 'yes' when asked to do so
```

Finally, you will have to delete terraform's state files:
```
rm -rf terraform.tfstate*
```
