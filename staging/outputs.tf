output "app_url" {
  value       = azurerm_linux_web_app.app.default_site_hostname
  description = "Public URL of the web app"
}

output "sql_fqdn" {
  value = module.db.sql_fqdn
}
