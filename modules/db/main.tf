# Deploy a managed MySQL server with public network access disabled by default.
# Using managed services reduces operational overhead and provides built-in backups.
resource "azurerm_mysql_flexible_server" "db" {
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
  public_network_access_enabled = Disabled
}

resource "azurerm_private_endpoint" "mysql_pe" {
  name                = "${var.prefix}-mysql-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "mysql-pe-conn"
    private_connection_resource_id = azurerm_mysql_flexible_server.db.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }
}
