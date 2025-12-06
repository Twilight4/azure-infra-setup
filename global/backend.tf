terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatestorage4123" # replace with your globally-unique storage name
    container_name       = "tfstate"
    key                  = "staging.terraform.tfstate"
  }
}
