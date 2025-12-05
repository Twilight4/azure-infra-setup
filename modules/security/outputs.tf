# Example Key Vault deployment is omitted here, but we prefer creating
# Key Vault and assigning access via Managed Identities. This module can
# be extended to add azurerm_key_vault resources and role assignments.

output "firewall_public_ip" {
  value = azurerm_public_ip.fw_pip.ip_address
}
