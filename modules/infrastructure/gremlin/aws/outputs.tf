output "host" {
  value       = "${aws_neptune_cluster.gremlin.endpoint}"
#  value       = "gremlin"
  description = "The port of the created AWS Neptune instance"
}

output "port" {
  value       = "8182"
  description = "The port of the gremlin server"
}