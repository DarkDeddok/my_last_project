output "elasticsearch_port" {
  value       = "80"
  description = "The port of the created elasticsearch instance"
}

output "elasticsearch_host" {
  value       = "${aws_elasticsearch_domain.es.endpoint}"
  description = "The host of the created elasticsearch instance"
}

output "kibana_host" {
  value       = "${element(split("/", element(split("://", aws_elasticsearch_domain.es.kibana_endpoint), 1)), 0)}"
  description = "The kibana URL"
}

output "kibana_port" {
  value       = "80"
  description = "The kibana port"
}

output "kibana_scheme" {
  value       = "http"
  description = "The kibana scheme"
}

output "kibana_path" {
  value       = "${element(split(".com", aws_elasticsearch_domain.es.kibana_endpoint), 1)}"
  description = "The kibana path"
}