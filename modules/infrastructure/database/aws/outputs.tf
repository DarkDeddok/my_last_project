output "database_host" {
  value       = "${split(":", module.db.this_db_instance_endpoint)[0]}"
  description = "The URI of the created resource"
}

output "database_port" {
  value       = "${module.db.this_db_instance_port}"
  description = "The Port of the created resource"
}

# mssql has no default database name in AWS.  So - we use the app_name (or any other string).
# this will be passed on to flyway, which will manage itself in this schema
output "database_name" {
  value       = "${lower(var.context.database.type) == "mssql" ? "${var.context.app_name}" : "${module.db.this_db_instance_name}"}"
  description = "The database that was created during setup in AWS"
}

# mssql has no default database name in AWS.  So - we use the app_name (or any other string).
# this will be passed on to flyway, which will manage itself in this schema
output "schema_name" {
  value       = "${lower(var.context.database.type) == "mssql" ? "${var.context.app_name}" : "${module.db.this_db_instance_name}"}"
  description = "The schema that was created during setup in AWS"
}