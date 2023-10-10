output "rabbitmq_hostname" {
  value       = "${helm_release.rabbitmq.name}"
  description = "The URI of the created resource"
}

output "vault_hostname" {
  value = "${var.context.app_name}-vault"
  description = "The URI of the created resource"
}
