provider "google-beta"{
  region = "${var.context.region}"
  version = "~> 2.14"
}

resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "redis" {
  service = "redis.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_redis_instance" "redis" {

  depends_on = [
    var.google_service_networking_connection
  ]

  name           = "${var.context.app_name}-redis"
  tier           = "STANDARD_HA"
  memory_size_gb = "${var.context.redis.google.memory}"

  region             = "${var.context.region}"

  authorized_network = "${var.private_network}"

  redis_version     = "REDIS_3_2"
  display_name      = "Redis Instance Managed by Terraform"
}

resource "google_dns_record_set" "redis" {
  name          = "redis.${var.google_dns_managed_zone.dns_name}"
  managed_zone  = "${var.google_dns_managed_zone.name}"
  type = "A"
  ttl  = 300
  rrdatas = ["${google_redis_instance.redis.host}"]
}