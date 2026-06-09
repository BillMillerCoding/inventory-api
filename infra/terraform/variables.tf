variable "resource_group_name" {
  description = "Existing resource group name used for all resources"
  type        = string
  default     = "rg-inventory-final"
}

variable "location" {
  description = "Fallback Azure region if resource group location lookup is unavailable"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment short name used in resource naming"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name prefix used in Azure resource names"
  type        = string
  default     = "inventoryapi"
}

variable "acr_sku" {
  description = "Azure Container Registry SKU"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be one of: Basic, Standard, Premium."
  }
}

variable "container_image_repository" {
  description = "Container repository name in ACR"
  type        = string
  default     = "inventory-api"
}

variable "container_image_tag" {
  description = "Container image tag used by Container App from Terraform"
  type        = string
  default     = "bootstrap"
}

variable "container_cpu" {
  description = "Container app CPU allocation"
  type        = number
  default     = 0.5
}

variable "container_memory" {
  description = "Container app memory allocation"
  type        = string
  default     = "1Gi"
}

variable "container_port" {
  description = "HTTP port exposed by the API container"
  type        = number
  default     = 8080
}

variable "cosmos_database_name" {
  description = "Cosmos DB SQL database name"
  type        = string
  default     = "inventorydb"
}

variable "cosmos_container_name" {
  description = "Cosmos DB SQL container name"
  type        = string
  default     = "items"
}

variable "cosmos_partition_key_path" {
  description = "Cosmos DB SQL container partition key path"
  type        = string
  default     = "/id"
}

variable "log_analytics_retention_days" {
  description = "Retention period in days for Log Analytics Workspace"
  type        = number
  default     = 30
}

variable "app_configuration_sku" {
  description = "Azure App Configuration SKU"
  type        = string

  default = "free"

  validation {
    condition     = contains(["free", "standard"], lower(var.app_configuration_sku))
    error_message = "app_configuration_sku must be free or standard."
  }
}

variable "app_name" {
  description = "Azure Container App name"
  type        = string
  default     = "inventory-api"
}

variable "name_suffix" {
  description = "Fixed short suffix appended to globally-scoped resource names (ACR, Cosmos, App Config). Committed once so every CI run produces identical names and Terraform apply is idempotent."
  type        = string
  default     = "final"
}

variable "stack_tag" {
  description = "Unique stack tag used to identify this deployment in shared resource groups"
  type        = string
  default     = "inventory-api-final"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    project     = "inventory-api"
    environment = "dev"
    managedby   = "terraform"
  }
}
