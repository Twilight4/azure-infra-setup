# Create a resource group to hold networking resources
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a storage account for the storage container
resource "azurerm_storage_account" "storage" {
  name                          = var.storage_account_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = true
}

resource "azurerm_storage_account_static_website" "website" {
  storage_account_id = azurerm_storage_account.storage.id
  error_404_document = var.index_404_document
  index_document     = var.index_document
}

# Using azurerm_storage_blob so that terraform apply automatically uploads static website file
resource "azurerm_storage_blob" "error404" {
  name                   = var.index_404_document
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = var.index_404_document
}

resource "azurerm_storage_blob" "index" {
  name                   = var.index_document
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = var.index_document
}
