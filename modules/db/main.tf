# Azure SQL Server (Free 250 MB Database)
resource "azurerm_mssql_server" "db_server" {
  name                = "${var.prefix}-sqlserver"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "12.0"

  # Admin credentials (store in Key Vault ideally)
  administrator_login          = var.db_admin
  administrator_login_password = var.db_password

  # Allow public access for free-tier app service access
  public_network_access_enabled = true
}

# Create the Free 250 MB SQL Database
resource "azurerm_mssql_database" "db" {
  name      = "${var.prefix}-sqldb"
  server_id = azurerm_mssql_server.db_server.id

  # Free tier settings
  sku_name                       = "GP_S_Gen5_1"
  max_size_gb                    = 0.25
  use_free_limit                 = true
  free_limit_exhaustion_behavior = "AutoPause"

  # Optional but recommended
  zone_redundant = false
}
