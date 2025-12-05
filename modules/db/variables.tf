variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "prefix" {
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

variable "sku_name" {
  type    = string
  default = "B_Gen5_1"
}

variable "storage_mb" {
  type    = number
  default = 51200
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "auto_grow_enabled" {
  type    = bool
  default = true
}
