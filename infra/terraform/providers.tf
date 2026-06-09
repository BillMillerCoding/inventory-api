provider "azurerm" {
  features {
    # Disable soft-delete recovery checks for App Configuration.
    # The OIDC service principal does not have permissions to query soft-deleted
    # resources, so we instruct the provider to skip that lookup entirely and
    # always create fresh resources.
    app_configuration {
      recover_soft_deleted = false
    }
  }
}

# NOTE:
# Authentication is expected via Azure CLI, managed identity, or workload identity/OIDC.
# Do not use client secrets in source-controlled Terraform configuration.
