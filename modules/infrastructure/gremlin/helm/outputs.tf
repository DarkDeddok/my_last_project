output "host" {
  value       = "${var.context.app_name}-janusgraph"
  description = "Gremlin Host"
}

output "port" {
  value       = "8182"
  description = "Gremlin Port"
}
