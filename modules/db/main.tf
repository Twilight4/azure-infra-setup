# Azure SQL Server (Free 250 MB Database)
resource "azurerm_mssql_server" "db_server" {
  name                = "${var.prefix}-sqlserver"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "12.0"

  # Admin credentials (store in Key Vault ideally)
  administrator_login          = var.db_admin
  administrator_login_password = var.db_password

  # Disable public access (use Private Endpoint only)
  public_network_access_enabled = false
}

# Create the Free 250 MB SQL Database
resource "azurerm_mssql_database" "db" {
  name      = "${var.prefix}-sqldb"
  server_id = azurerm_mssql_server.db_server.id

  # Free tier settings
  edition     = "Basic"
  max_size_gb = 0.25

  # Optional but recommended
  zone_redundant = false
}

# Private Endpoint for Azure SQL
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.prefix}-sql-pe"
  location            = var.location
  resource_group_name = var.resource_group_name

  # This subnet must have "Private Endpoint Network Policies = Disabled"
  subnet_id = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "sql-pe-conn"
    private_connection_resource_id = azurerm_mssql_server.db_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

# Private DNS Zone for Azure SQL
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "${var.prefix}-sqldns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "sql_dns_record" {
  name                = azurerm_mssql_server.db_server.name
  zone_name           = azurerm_private_dns_zone.sql_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  records = [
    azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address
  ]
}
