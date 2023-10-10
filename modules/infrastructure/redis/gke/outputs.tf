output "redis_port" {
  value       = "${google_redis_instance.redis.port}"
  description = "The port of the created redis instance"
}

output "redis_host" {
  value       = "redis.${var.context.app_name}.gcloud.com"
  description = "The host of the created redis instance"
}

output "redis_password" {
  value = "" #no password in Cloud Memorystore in Google
  description = "Redis password"
}

output "redis_mode" {
  value = "single"
  description = "Redis Mode"
}
