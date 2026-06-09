data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

resource "random_string" "suffix" {
  length  = 12
  special = false
  upper   = false
  numeric = true
}

locals {
  resource_group_name     = data.azurerm_resource_group.existing.name
  resource_group_location = try(data.azurerm_resource_group.existing.location, var.location)

  name_prefix = "${var.project_name}${var.environment}${random_string.suffix.result}"

  acr_name                        = substr(replace("acr${local.name_prefix}", "-", ""), 0, 50)
  log_analytics_workspace_name    = substr("law-${var.project_name}-${var.environment}-${random_string.suffix.result}", 0, 63)
  container_apps_environment_name = substr("cae-${var.project_name}-${var.environment}-${random_string.suffix.result}", 0, 60)
  cosmos_account_name             = substr(replace("cosmos${local.name_prefix}", "-", ""), 0, 44)
  app_configuration_name          = substr("appcs-inventory-${random_string.suffix.result}", 0, 50)
  container_app_name              = substr("${var.app_name}-${var.environment}", 0, 32)

  common_tags = merge(var.tags, {
    project     = "inventory-api"
    environment = var.environment
    stack       = var.stack_tag
    managedby   = "terraform"
  })
}

# Azure Container Registry hosts API container images with admin user disabled.
resource "azurerm_container_registry" "this" {
  name                = local.acr_name
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = local.common_tags
}

# Central workspace for diagnostics and logs.
resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_workspace_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.common_tags
}

# Managed configuration store for future dynamic feature/config rollout.
resource "azurerm_app_configuration" "this" {
  name                = local.app_configuration_name
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  sku                 = lower(var.app_configuration_sku)
  tags                = local.common_tags
}

# Serverless Cosmos DB SQL API account for inventory data.
resource "azurerm_cosmosdb_account" "this" {
  name                = local.cosmos_account_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = local.common_tags

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = local.resource_group_location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.cosmos_database_name
  resource_group_name = local.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
}

resource "azurerm_cosmosdb_sql_container" "this" {
  name                  = var.cosmos_container_name
  resource_group_name   = local.resource_group_name
  account_name          = azurerm_cosmosdb_account.this.name
  database_name         = azurerm_cosmosdb_sql_database.this.name
  partition_key_paths   = [var.cosmos_partition_key_path]
  partition_key_version = 2
}

# Container Apps Environment provides shared networking and observability for apps.
resource "azurerm_container_app_environment" "this" {
  name                       = local.container_apps_environment_name
  location                   = local.resource_group_location
  resource_group_name        = local.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  tags                       = local.common_tags
}

# Container App runs the Inventory API with a system-assigned managed identity.
resource "azurerm_container_app" "this" {
  name                         = local.container_app_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = local.resource_group_name
  revision_mode                = "Single"
  tags                         = local.common_tags

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = azurerm_container_registry.this.login_server
    identity = "system"
  }

  ingress {
    external_enabled = true
    target_port      = var.container_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "inventory-api"
      image  = "${azurerm_container_registry.this.login_server}/${var.container_image_repository}:${var.container_image_tag}"
      cpu    = var.container_cpu
      memory = var.container_memory

      env {
        name  = "ASPNETCORE_URLS"
        value = "http://+:${var.container_port}"
      }

      env {
        name  = "COSMOS_ENDPOINT"
        value = azurerm_cosmosdb_account.this.endpoint
      }

      env {
        name  = "COSMOS_DATABASE"
        value = azurerm_cosmosdb_sql_database.this.name
      }

      env {
        name  = "COSMOS_CONTAINER"
        value = azurerm_cosmosdb_sql_container.this.name
      }

      env {
        name  = "APP_CONFIG_ENDPOINT"
        value = azurerm_app_configuration.this.endpoint
      }
    }
  }
}

# Allow Container App managed identity to pull images from ACR without admin credentials.
resource "azurerm_role_assignment" "container_app_acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.this.identity[0].principal_id

  skip_service_principal_aad_check = true
}
