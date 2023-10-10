# if the host is defined, then use the custom host
output "database_host" {
  value       = "${length(var.context.database.helm.host) > 0 ? "${var.context.database.helm.host}" : ("${lower(var.context.database.type)}" == "postgres" ? "${helm_release.database[0].name}-postgresql" : "${helm_release.database[0].name}-primary")}"
  description = "The URI of the created resource"
}

# if the port is defined, then use the custom port
output "database_port" {
  value       = "${length(var.context.database.helm.port) > 0 ? "${var.context.database.helm.port}" : ("${lower(var.context.database.type)}" == "postgres" ? "5432" : "3306")}"
  description = "The URI of the created resource"
}

output "database_name" {
  value       = ""
  description = "No database was created during spinup of the pod, so returning nothing"
}

output "schema_name" {
  value       = ""
  description = "No schema was created during spinup of the pod, so returning nothing"
}