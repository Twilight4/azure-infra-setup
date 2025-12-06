# Create a resource group to hold networking resources.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# App Service Plan
resource "azurerm_service_plan" "app_plan" {
  name                = "${var.prefix}-asp"
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = "Linux"
  sku_name = "F1"
}

# Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    # F1 disallows always_on = true
    always_on = false
  }
}
