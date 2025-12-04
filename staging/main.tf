# Compose modules into a staging environment. This file shows how the
# modules connect: network -> security -> compute -> db.

module "network" {
  source = "../modules/network"

  resource_group_name = "rg-staging"
  location            = "westeurope"
  prefix              = "stg"

  # Hub address space and the AzureFirewallSubnet prefixes
  hub_address_space      = ["10.0.0.0/16"]
  hub_fw_subnet_prefixes = ["10.0.1.0/24"]

  # Spokes map: each spoke gets a VNet with an address space and
  # optional subnet prefixes. This is flexible for multi-tier apps.
  spokes = {
    web = { address_space = "10.1.0.0/16", subnet_prefixes = ["10.1.1.0/24"] }
    app = { address_space = "10.2.0.0/16", subnet_prefixes = ["10.2.1.0/24"] }
    db  = { address_space = "10.3.0.0/16", subnet_prefixes = ["10.3.1.0/24"] }
  }

  allow_gateway_transit = true
}
