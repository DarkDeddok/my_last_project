variable "context" {}

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

variable "elasticsearch" {
    type = object({
        host = string
        port = string
    })
}