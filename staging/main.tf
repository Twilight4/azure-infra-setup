# Compose modules into a staging environment. This file shows how the
# modules connect: network -> security -> compute -> db.

module "network" {
  source = "../modules/network"

  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix

  # Hub address space
  hub_address_space = ["10.0.0.0/16"]

  # Spokes map: each spoke gets a VNet with an address space and
  # optional subnet prefixes. This is flexible for multi-tier apps.
  spokes = {
    web = { address_space = "10.1.0.0/16", subnet_prefixes = ["10.1.1.0/24"] }
    app = { address_space = "10.2.0.0/16", subnet_prefixes = ["10.2.1.0/24"] }
    db  = { address_space = "10.3.0.0/16", subnet_prefixes = ["10.3.1.0/24"] }
  }

  allow_gateway_transit = false
}

module "security" {
  source = "../modules/security"

  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix

  # Pass web subnet id for NSG association
  web_subnet_id = module.network.spoke_subnet_ids["web"]
}

module "compute" {
  source = "../modules/compute"

  prefix              = var.prefix
  resource_group_name = var.resource_group_name
  location            = var.location

  database_hostname = module.db.sql_fqdn
  database_username = var.database_username
  database_password = var.database_password
}

module "db" {
  source = "../modules/db"

  prefix              = var.prefix
  resource_group_name = var.resource_group_name
  location            = var.location

  db_admin    = var.db_admin
  db_password = var.db_password

  # Public SQL access with firewall rules limited by allowed_ips
  allowed_ips = var.allowed_ips
}
