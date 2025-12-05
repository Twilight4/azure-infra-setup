# Public IP for Azure Firewall. We use a Standard SKU static IP because
# Azure Firewall requires a dedicated PIP and resilient SKU.
resource "azurerm_public_ip" "fw_pip" {
  name                = "${var.prefix}-fw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Azure Firewall requires Standard SKU PIP for zone resilient deployments.
  allocation_method = "Static"
  sku               = "Standard"
}

# Deploy Azure Firewall into the hub firewall subnet. The firewall
# provides centralized filtering and can be used for both north-south
# and east-west traffic if routed appropriately.
resource "azurerm_firewall" "azfw" {
  name                = "${var.prefix}-azfw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"

  ip_configuration {
    name = "configuration"
    # This subnet id should point at the AzureFirewallSubnet created
    # in the network module. The module consumer must pass it in.
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

# Example Network Security Group for a web subnet. NSGs are cheaper
# and faster for packet filtering than Azure Firewall, and they provide
# micro-segmentation at the subnet or NIC level.
resource "azurerm_network_security_group" "web_nsg" {
  name                = "${var.prefix}-web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Add a sample rule to the NSG that allows inbound HTTP/HTTPS from
# Internet into the web subnet. In production, prefer Application
# Gateway/WAF in front of web servers and restrict direct Internet access.
resource "azurerm_network_security_rule" "allow_http" {
  name                    = "Allow-HTTP"
  priority                = 100
  direction               = "Inbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  destination_port_ranges = ["80", "443"]

  # Source is Internet — you could tighten this to known IPs/cidrs.
  source_address_prefix = "Internet"

  # Destination set to VirtualNetwork allows traffic to any IP in the VNet.
  destination_address_prefix = "VirtualNetwork"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web_nsg.name
}
