# App Service Plan (Free F1)
resource "azurerm_service_plan" "app_plan" {
  name                = "${var.prefix}-asp"
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = "Linux"
  sku_name = "F1"
}

# Linux Web App (Free tier)
resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    # F1 disallows always_on = true
    always_on = false
  }

  app_settings = {
    "DATABASE_HOST"     = var.database_hostname
    "DATABASE_USER"     = var.database_username
    "DATABASE_PASSWORD" = var.database_password
  }
}
