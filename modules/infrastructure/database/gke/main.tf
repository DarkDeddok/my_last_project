provider "google-beta" {
  region = "${var.context.region}"
  version = "~> 2.14"
}

# Enable the Service Working API to allow Terraform
# to "peer" our Cloud SQL network with the network
# running Google Kubernetes Engine.  Peering connects
# two different cloud networks together so that they act
# as a single network and the servers on each can talk to
# one another, which is what we need if we want our services
# running on Google Kubernetes Engine to be able to talk to
# our Cloud SQL instance
resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Enable the SQL Component API service so that Terraform
# can create the Cloud SQL instance
resource "google_project_service" "sqlcomponent" {
  service = "sql-component.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Enable the SQL Admin API service so that Terraform
# can create our databases first user
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}


resource "google_sql_database_instance" "database" {
  provider         = "google-beta"
  name             = "${var.context.app_name}-database"
  region           = "${var.context.region}"
  database_version = "${lower(var.context.database.type) == "postgres" ? "POSTGRES_11" : "MYSQL_5_7"}"

  depends_on = [
    var.google_service_networking_connection
  ]

  settings {
    tier      = "${var.context.database.google.instance_class}"
    disk_type = "PD_SSD"

    ip_configuration {
        ipv4_enabled = "false"
        private_network = "${var.private_network}"
    }

    backup_configuration {
      enabled = true
      start_time = "01:00"
    }

    maintenance_window {
      day          = 6
      hour         = 1
      update_track = "stable"
    }
  }
}

resource "google_dns_record_set" "database" {
  name          = "database.${var.google_dns_managed_zone.dns_name}"
  managed_zone  = "${var.google_dns_managed_zone.name}"
  type = "A"
  ttl  = 300
  rrdatas = ["${google_sql_database_instance.database.private_ip_address}"]
}

resource "google_sql_database" "openiam" {
  name     = "${var.context.database.openiam.database_name}"
  instance = "${google_sql_database_instance.database.name}"
}

resource "google_sql_database" "activiti" {
  name     = "${var.context.database.activiti.database_name}"
  instance = "${google_sql_database_instance.database.name}"
}

resource "google_sql_user" "root" {
  name     = "${var.context.database.root.user}"
  instance = "${google_sql_database_instance.database.name}"
  host     = ""
  password = "${var.context.database.root.password}"
}

resource "google_sql_user" "openiam" {
  name     = "${var.context.database.openiam.user}"
  instance = "${google_sql_database_instance.database.name}"
  host     = ""
  password = "${var.context.database.openiam.password}"
}

resource "google_sql_user" "activiti" {
  name     = "${var.context.database.activiti.user}"
  instance = "${google_sql_database_instance.database.name}"
  host     = ""
  password = "${var.context.database.activiti.password}"
}