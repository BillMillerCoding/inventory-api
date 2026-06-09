output "resource_group_name" {
  description = "Resource group name used by this deployment"
  value       = local.resource_group_name
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.this.login_server
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "application_insights_id" {
  description = "Application Insights resource ID"
  value       = azurerm_application_insights.this.id
}

output "application_insights_name" {
  description = "Application Insights resource name"
  value       = azurerm_application_insights.this.name
}

output "application_insights_connection_string" {
  description = "Application Insights connection string for future runtime wiring"
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

output "container_apps_environment_name" {
  description = "Container Apps Environment name"
  value       = azurerm_container_app_environment.this.name
}

output "container_app_name" {
  description = "Container App name"
  value       = azurerm_container_app.this.name
}

output "container_app_url" {
  description = "Container App public URL"
  value       = "https://${azurerm_container_app.this.latest_revision_fqdn}"
}

output "cosmos_account_name" {
  description = "Cosmos DB account name"
  value       = azurerm_cosmosdb_account.this.name
}

output "cosmos_endpoint" {
  description = "Cosmos DB SQL API endpoint"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "cosmos_database_name" {
  description = "Cosmos DB SQL database name"
  value       = azurerm_cosmosdb_sql_database.this.name
}

output "cosmos_container_name" {
  description = "Cosmos DB SQL container name"
  value       = azurerm_cosmosdb_sql_container.this.name
}

output "app_configuration_endpoint" {
  description = "App Configuration endpoint"
  value       = azurerm_app_configuration.this.endpoint
}
