# Core deployment settings
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project/application name prefix used in resource naming"
  type        = string
  default     = "inventory-api"
}
