output "database_port" {
  value       = "${lower(var.context.database.type) == "postgres" ? "5432" : "3306"}"
  description = "The URI of the created resource"
}

output "database_host" {
  value       = "database.${var.context.app_name}.gcloud.com"
  description = "The URI of the created resource"
}

output "database_name" {
  value       = ""
  description = "The database that was created when this app was setup in GKE"
}

output "schema_name" {
  value       = ""
  description = "The schema that was created when this app was setup in GKE"
}