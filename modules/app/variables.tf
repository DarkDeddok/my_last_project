variable "kube_host" {
    default = ""
}
variable "kube_token" {
    default = ""
}
variable "kube_cluster_ca_certificate" {
    default = ""
}
variable "kube_client_certificate" {
    default = ""
}
variable "kube_client_key" {
    default = ""
}

variable "elasticsearch" {
    type = object({
        host = string
        port = string
        kibana_full_url = string
    })
}

variable "gremlin" {
    type = object({
        host = string
        port = string
    })
}

variable "database" {
    type = object({
        host = string
        port = string
        created_database = string
        flywayBaselineVersion = string
        flywayCommand = string
    })
}

variable "redis" {
    type = object({
        host = string
        port = string
        mode = string
    })
}

variable "rabbitmq" {
    type = object({
        user = string
        password = string
        host = string
        cookie_name = string
    })
}

variable "vault" {
    type = object({
        host = string
    })
}

variable "context" {}

variable "cloud_provider" {}
