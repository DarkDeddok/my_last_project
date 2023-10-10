variable "context" {}

variable "elasticsearch" {
    type = object({
        host = string
        port = string
    })
}