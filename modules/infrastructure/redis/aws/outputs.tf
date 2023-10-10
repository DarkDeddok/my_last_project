output "redis_port" {
  value       = "${aws_elasticache_cluster.default.cache_nodes.0.port}"
  description = "The port of the created redis instance"
}

output "redis_host" {
  value       = "${aws_elasticache_cluster.default.cache_nodes.0.address}"
  description = "The host of the created redis instance"
}

output "redis_password" {
  value = "" #no password in AWS Redis
  description = "Redis password"
}

output "redis_mode" {
  value = "single"
  description = "Redis Mode"
}
