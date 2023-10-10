terraform {
  required_version = ">= 0.12.21"
}

provider "google" {
  region = "${var.context.region}"
  version = "~> 2.14"
}

provider "google-beta"{
  region = "${var.context.region}"
  version = "~> 2.14"
}


resource "google_compute_network" "default" {
  name                    = "${var.context.app_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "${var.context.app_name}"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.context.region}"
  private_ip_google_access = true
}

resource "google_dns_managed_zone" "internal" {
  provider         = "google-beta"
  name             = "${var.context.app_name}"
  dns_name         = "${var.context.app_name}.gcloud.com."
  visibility       = "private"

  private_visibility_config {
    networks {
      network_url = "${google_compute_network.default.self_link}"
    }
  }
}

resource "google_compute_global_address" "internal" {
  provider      = "google-beta"
  name          = "${var.context.app_name}-internal"
  purpose       = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 16
  network       = "${google_compute_network.default.self_link}"
}

resource "google_service_networking_connection" "internal" {
  provider      = "google-beta"
  network       = "${google_compute_network.default.self_link}"
  service       = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.internal.name}"]
}

data "google_container_engine_versions" "default" {
    location = "${var.context.region}"
}

resource "google_container_cluster" "default" {
  name               = "${var.context.app_name}"
  location           = "${var.context.region}"
  min_master_version = "1.23"
  network            = "${google_compute_network.default.name}"
  subnetwork         = "${google_compute_subnetwork.default.name}"

  node_version       = "1.23"

  // Use legacy ABAC until these issues are resolved:
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true

  # want to use IP Aliases so that
  # this is a VPC-native cluster which makes
  # connecting to our database later much easier
  ip_allocation_policy {
    use_ip_aliases = true
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1
}

resource "google_container_node_pool" "default" {
  name       = "${var.context.app_name}-pool"
  location   = "${var.context.region}"
  cluster    = "${google_container_cluster.default.name}"
  node_count = "${var.context.replica_count}"

  node_config {
    preemptible  = false
    machine_type = "${var.context.kubernetes.gke.machine_type}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }
}

resource "null_resource" "update_kubeconfig" {

  provisioner "local-exec" {
    command = <<EOT
      gcloud container clusters get-credentials ${var.context.app_name} --region ${var.context.region};
   EOT
  }
  depends_on = [
    "google_container_cluster.default"
  ]
}


data "google_client_config" "current" {

  depends_on = [
    "google_container_cluster.default"
  ]
}

resource "google_compute_address" "default" {
  name    = "${var.context.app_name}"
  region  = "${var.context.region}"
}

module "kubernetes" {
  source = "../../kubernetes"
  kube_host                   = "${google_container_cluster.default.endpoint}"
  kube_token                  = "${data.google_client_config.current.access_token}"
  kube_client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
  kube_client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
  kube_cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"

  context = var.context
}

module "helm" {
  source = "../../helm"
  kube_host                   = "${google_container_cluster.default.endpoint}"
  kube_token                  = "${data.google_client_config.current.access_token}"
  kube_client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
  kube_client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
  kube_cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"

  context = var.context
  cloud_provider = "gke"
}

module "database" {
  source = "../../infrastructure/database/gke"
  private_network = "${google_compute_network.default.self_link}"

  google_service_networking_connection = google_service_networking_connection.internal
  google_dns_managed_zone = google_dns_managed_zone.internal
  context = var.context
}

module "elasticsearch" {
  source = "../../infrastructure/elasticsearch/helm"
  kube_host                   = "${google_container_cluster.default.endpoint}"
  kube_token                  = "${data.google_client_config.current.access_token}"
  kube_client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
  kube_client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
  kube_cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"
  context = var.context
}

module "kibana" {
  source = "../../infrastructure/kibana/helm"
  kube_host                   = "${google_container_cluster.default.endpoint}"
  kube_token                  = "${data.google_client_config.current.access_token}"
  kube_client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
  kube_client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
  kube_cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"
  context = var.context
}

module "monitoring" {
  source = "../../infrastructure/monitoring/helm"
  context = var.context

  kube_host                   = "${google_container_cluster.default.endpoint}"
  kube_token                  = "${data.google_client_config.current.access_token}"
  kube_client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
  kube_client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
  kube_cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"

  database = {
    host = "${module.database.database_host}"
    port = "${module.database.database_port}"
    user : "${var.context.database.root.user}"
    password = "${var.context.database.root.password}"
  }

  redis = {
    host = "${module.redis.redis_host}"
    port = "${module.redis.redis_port}"
    password = "${module.redis.redis_password}"
  }

  rabbitmq = {
    user = "${var.context.rabbitmq.user}"
    password = "${var.context.rabbitmq.password}"
    host = "${module.helm.rabbitmq_hostname}"
  }

  kibana = {
    kibana_port = "${module.kibana.kibana_port}"
    kibana_host = "${module.kibana.kibana_host}"
    kibana_scheme = "${module.kibana.kibana_scheme}"
    kibana_path = "${module.kibana.kibana_path}"
  }

  elasticsearch = {
    host = "${module.elasticsearch.elasticsearch_host}"
    port = "${module.elasticsearch.elasticsearch_port}"
  }

  cloud_provider = "gke"
}

module "redis" {
  source = "../../infrastructure/redis/gke"
  private_network = "${google_compute_network.default.self_link}"

  google_service_networking_connection = google_service_networking_connection.internal
  google_dns_managed_zone = google_dns_managed_zone.internal

  context = var.context
}

module "gremlin" {
  source                = "../../infrastructure/gremlin/gke"
  context               = var.context
  elasticsearch = {
    host = "${module.elasticsearch.elasticsearch_host}"
    port = "${module.elasticsearch.elasticsearch_port}"
  }

  kube_host                   = "${google_container_cluster.default.endpoint}"
  kube_token                  = "${data.google_client_config.current.access_token}"
  kube_client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
  kube_client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
  kube_cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"
}

module "openiam-app" {
  source = "../../app"
  kube_host                   = "${google_container_cluster.default.endpoint}"
  kube_token                  = "${data.google_client_config.current.access_token}"
  kube_client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
  kube_client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
  kube_cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"

  context = var.context

  database = {
    host = "${module.database.database_host}"
    port = "${module.database.database_port}"
    created_database = "${module.database.database_name}"
    flywayBaselineVersion = "${var.context.database.flywayBaselineVersion}"
    flywayCommand = "${var.context.database.flywayCommand}"
  }

  elasticsearch = {
    host = "${module.elasticsearch.elasticsearch_host}"
    port = "${module.elasticsearch.elasticsearch_port}"
    kibana_full_url = "${module.kibana.kibana_scheme}://${module.kibana.kibana_host}${module.kibana.kibana_path}"
  }
  redis = {
    host = "${module.redis.redis_host}"
    port = "${module.redis.redis_port}"
    mode = "${module.redis.redis_mode}"
  }

  rabbitmq = {
    user = "${var.context.rabbitmq.user}"
    password = "${var.context.rabbitmq.password}"
    host = "${module.helm.rabbitmq_hostname}"
    cookie_name = "${var.context.rabbitmq.cookie_name}"
  }

  vault = {
    host = "${module.helm.vault_hostname}"
  }

  gremlin = {
    host = "${module.gremlin.host}"
    port = "${module.gremlin.port}"
  }

  cloud_provider = "gke"
}
