variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "prefix" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "vm_sku" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "app_subnet_id" {
  type = string
}
