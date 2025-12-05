# Create a resource group to hold networking resources.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create the hub virtual network which will host shared services
# (firewall, NAT, gateways). The hub address space can be larger to
# accommodate multiple spoke routable ranges.
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.prefix}-hub-vnet"
  address_space       = var.hub_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create the subnet specifically named for Azure Firewall. This name
# is required by Azure Firewall (AzureFirewallSubnet).
resource "azurerm_subnet" "hub_fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.hub_fw_subnet_prefixes
}

resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "PrivateEndpointSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.hub_pe_subnet_prefixes

  # Required for Private Endpoints
  enforce_private_link_endpoint_network_policies = false
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

# VNet peering from hub -> spoke. We create peering entries in the hub
# for each spoke, enabling forwarded traffic and transit if needed.
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = azurerm_virtual_network.spoke_vnet

  name                      = "hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = each.value.id

  # Allow hub to forward traffic to spokes and (optionally) allow
  # gateway transit when a hub has a gateway and you want spokes to
  # use the hub's gateway.
  allow_forwarded_traffic = true
  allow_gateway_transit   = var.allow_gateway_transit
  use_remote_gateways     = false
}

# Optionally create the reverse peering (spoke -> hub). Some setups
# require both sides to be peered explicitly; doing both sides here
# ensures traffic can route in both directions.
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = azurerm_virtual_network.spoke_vnet

  name                      = "${each.key}-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = each.value.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

  allow_forwarded_traffic = true
  use_remote_gateways     = var.allow_gateway_transit
}
