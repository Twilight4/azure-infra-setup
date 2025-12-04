variable "db_admin" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
