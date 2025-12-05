# Deploy a managed MySQL server with public network access disabled by default.
# Using managed services reduces operational overhead and provides built-in backups.
resource "azurerm_mysql_server" "db" {
  name                = "${var.prefix}-mysql"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Admin credentials should ideally come from Key Vault / secure source
  # and not be stored in plain text TF variables in a repo.
  administrator_login          = var.db_admin
  administrator_login_password = var.db_password

  # Sizing SKU — choose according to performance needs.
  sku_name              = var.sku_name
  storage_mb            = var.storage_mb
  backup_retention_days = var.backup_retention_days
  auto_grow_enabled     = var.auto_grow_enabled

  # Disallow public access by default — recommend private endpoint or vnet integration.
  public_network_access_enabled = false
}

# Configure firewall rule to allow the application subnet (or the NAT egress IP)
# to reach the database. If using private endpoint, firewall rules may be unnecessary.
resource "azurerm_mysql_firewall_rule" "allow_app_subnet" {
  name                = "allow_app_subnet"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.db.name

  # Terraform's mysql firewall rule expects an IP range. If your app lives
  # in a VNet, you might instead configure Private Endpoint or VNet Service Endpoint.
  start_ip_address = var.app_subnet_start_ip
  end_ip_address   = var.app_subnet_end_ip
}
