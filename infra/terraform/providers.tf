provider "azurerm" {
  features {}
}

# NOTE:
# Authentication is expected via Azure CLI, managed identity, or workload identity/OIDC.
# Do not use client secrets in source-controlled Terraform configuration.
