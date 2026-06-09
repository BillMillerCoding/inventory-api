terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-inventory-final"
    storage_account_name = "stinventoryapifinal"
    container_name       = "tfstate"
    key                  = "inventory-api.tfstate"
  }
}
