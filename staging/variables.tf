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
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}

variable "database_username" {
  type = string
}
variable "database_password" {
  type = string
}

variable "allowed_ips" {
  type = list(string)
}
