output "redis_port" {
  value       = "${var.context.redis.helm.sentinel.enabled ? 26379 : 6379}"
  description = "The port of the created redis instance"
}

output "redis_host" {
  value       = "${var.context.app_name}-redis-${var.context.redis.helm.sentinel.enabled ? "headless" : "master"}"
  description = "The host of the created redis instance"
}

output "redis_password" {
  value = "${var.context.redis.password}"
  description = "Redis password"
}

output "redis_mode" {
  value       = "${var.context.redis.helm.sentinel.enabled ? "sentinel" : "single"}"
  description = "Redis Mode"
}
