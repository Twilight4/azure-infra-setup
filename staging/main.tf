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
  hub_pe_subnet_prefixes = ["10.0.2.0/24"]

  # Spokes map: each spoke gets a VNet with an address space and
  # optional subnet prefixes. This is flexible for multi-tier apps.
  spokes = {
    web = { address_space = "10.1.0.0/16", subnet_prefixes = ["10.1.1.0/24"] }
    app = { address_space = "10.2.0.0/16", subnet_prefixes = ["10.2.1.0/24"] }
    db  = { address_space = "10.3.0.0/16", subnet_prefixes = ["10.3.1.0/24"] }
  }

  allow_gateway_transit = true
}

# Security module uses outputs from the network module (e.g. firewall subnet id)
module "security" {
  source = "../modules/security"

  resource_group_name = "rg-staging"
  location            = "westeurope"
  prefix              = "stg"

  # Pass the hub firewall subnet id so the firewall can be deployed there.
  firewall_subnet_id = module.network.hub_firewall_subnet_id
}

module "compute" {
  source = "../modules/compute"

  resource_group_name = "rg-staging"
  location            = "westeurope"
  prefix              = "stg"

  # initial instance count; use autoscale resource for production scaling policies
  instance_count = 2
  vm_sku         = "Standard_DS2_v2"
  admin_username = "appadmin"

  # Reference app subnet id from the network module; here we assume
  # module.network exposes an output app_subnet_id (or map of subnet ids).
  app_subnet_id = element(values(module.network.spoke_vnets), 1)
}

# DB module: create a managed DB and restrict access to the app subnet range.
module "db" {
  source = "../modules/db"

  resource_group_name = "rg-staging"
  location            = "westeurope"
  prefix              = "stg"

  db_admin    = var.db_admin
  db_password = var.db_password
}
