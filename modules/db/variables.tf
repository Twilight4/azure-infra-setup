variable "prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "db_admin" {
  description = "Database admin username (preferably a service principal or managed identity)."
  type        = string
}

variable "db_password" {
  description = "Database admin password. Use Key Vault and do not store in repo."
  type        = string
  sensitive   = true
}

variable "allowed_ips" {
  type    = list(string)
  default = []
}
