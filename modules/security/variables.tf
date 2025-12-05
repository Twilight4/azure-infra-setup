variable "resource_group_name" {
  type        = string
  description = "Resource group for security resources."
}

variable "location" {
  type        = string
  description = "Azure region for security resources."
}

variable "prefix" {
  type        = string
  description = "Naming prefix."
}
