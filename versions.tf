# Specify required Terraform and provider versions to ensure reproducible runs.
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Lock to a recent major provider to avoid breaking changes.
      version = ">= 4.0"
    }
  }
}
