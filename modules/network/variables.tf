variable "resource_group_name" {
  description = "Name of the resource group to create networking resources in."
  type        = string
}

variable "location" {
  description = "Azure region (e.g. westeurope)."
  type        = string
}

variable "prefix" {
  description = "Prefix used for naming resources (e.g. dev, prod, stg)."
  type        = string
}

variable "hub_address_space" {
  description = "Address space for the hub VNet (list of CIDR blocks)."
  type        = list(string)
}

variable "hub_fw_subnet_prefixes" {
  description = "Subnet prefixes for AzureFirewallSubnet in the hub."
  type        = list(string)
}

variable "spokes" {
  description = "Map of spoke names to their configuration (address_space, optional subnet_prefixes)."
  type = map(object({
    address_space   = string
    subnet_prefixes = optional(list(string))
  }))
}

variable "allow_gateway_transit" {
  description = "Whether the hub should allow gateway transit for spokes."
  type        = bool
  default     = false
}
