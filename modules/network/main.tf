# Create a resource group to hold networking resources.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create the hub virtual network which will host shared services
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.prefix}-hub-vnet"
  address_space       = var.hub_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a set of spoke VNets. Using for_each lets the module accept
# an input map of spokes and create resources for each entry.
resource "azurerm_virtual_network" "spoke_vnet" {
  for_each            = var.spokes
  name                = "${var.prefix}-${each.key}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Each spoke supplies its own address space (string) so we wrap it
  # into a single-element list as the provider expects a list.
  address_space = [each.value.address_space]
}

# Create subnets for each spoke VNet: usually web/app/db subnets live
# inside the spoke VNet. This example demonstrates creating a single
# default subnet per spoke; you can expand with more subnets per spoke.
resource "azurerm_subnet" "spoke_subnet" {
  for_each             = azurerm_virtual_network.spoke_vnet
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = each.value.name

  # If spokes passed a specific subnet prefix map, prefer that, else
  # leave it to be provided by a higher-level variable.
  address_prefixes = lookup(var.spokes, each.key, {}).subnet_prefixes
}
