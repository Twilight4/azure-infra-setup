# Export useful IDs for other modules (firewall subnet, spokes, etc.).
output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

output "hub_firewall_subnet_id" {
  value = azurerm_subnet.hub_fw_subnet.id
}

output "spoke_vnets" {
  # return a map of spoke names -> vnet ids for easy consumption
  value = { for k, v in azurerm_virtual_network.spoke_vnet : k => v.id }
}
