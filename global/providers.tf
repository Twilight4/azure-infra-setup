# Configure the AzureRM provider.
# The `features {}` block is required (even when empty) by the provider.
provider "azurerm" {
  features {}
  # If you want to pin a subscription or tenant explicitly, you can set
  # subscription_id and tenant_id here, or rely on environment variables
  # (ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID)
}
