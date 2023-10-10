variable "kube_host" {
    default = ""
}
variable "kube_token" {
    default = ""
}
variable "kube_client_certificate" {
    default = ""
}
variable "kube_client_key" {
    default = ""
}
variable "kube_cluster_ca_certificate" {
    default = ""
}

variable "cloud_provider" {}

variable "context" {}

variable "database" {
    type = object({
        host = string
        port = string
        password = string
        user = string
    })
}

variable "redis" {
    type = object({
        host = string
        password = string
    })
}

variable "rabbitmq" {
    type = object({
        user = string
        password = string
        host = string
    })
}

variable "kibana" {
    type = object({
        kibana_port = string
        kibana_host = string
        kibana_scheme = string
        kibana_path = string
    })
}

variable "elasticsearch" {
    type = object({
        host = string
        port = string
    })
}