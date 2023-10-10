output "kibana_host" {
  value       = "${var.context.app_name}-kibana-kibana"
  description = "The kibana URL"
}

output "kibana_port" {
  value       = "5601"
  description = "The kibana port"
}

output "kibana_scheme" {
  value       = "http"
  description = "The kibana scheme"
}

output "kibana_path" {
  value       = "/_plugin/kibana"
  description = "The kibana path"
}