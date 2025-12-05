output "spoke_vnets" {
  # return a map of spoke names -> vnet ids for easy consumption
  value = { for k, v in azurerm_virtual_network.spoke_vnet : k => v.id }
}

output "spoke_subnet_ids" {
  value = { for k, v in azurerm_subnet.spoke_subnet : k => v.id }
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "location" {
  value = azurerm_resource_group.rg.location
}

