# Inventory API Final Project

Cloud-native Inventory API built with ASP.NET Core, Docker, Terraform, and GitHub Actions with OIDC-based Azure authentication.

## Project Overview

This project delivers an end-to-end Azure deployment pipeline for a containerized Inventory API.

- API: ASP.NET Core Web API
- Infrastructure: Terraform
- CI/CD: GitHub Actions
- Auth: OIDC via azure/login@v2
- Resource group target: rg-inventory-final (existing)

## Azure Architecture

Terraform provisions the following services in rg-inventory-final:

- Azure Container Registry (Basic, admin disabled)
- Log Analytics Workspace
- Application Insights (workspace-based)
- Container Apps Environment
- Azure Container App (system-assigned managed identity)
- Azure Cosmos DB (Serverless, SQL API, database + container)
- Azure App Configuration

## Security Model

- GitHub Actions uses OIDC only with repository variables:
  - AZURE_CLIENT_ID
  - AZURE_TENANT_ID
  - AZURE_SUBSCRIPTION_ID
- No client secrets, passwords, or static credentials in workflows
- ACR admin user is disabled
- Container App uses system-assigned managed identity
- Application service registration includes DefaultAzureCredential for future Azure SDK integration

## API Status

Implemented endpoints:

- GET /api/items
- GET /api/items/{id}
- POST /api/items
- PUT /api/items/{id}
- DELETE /api/items/{id}
- GET /health

Current data layer uses an in-memory repository with a clean interface to enable later Cosmos DB implementation.

Swagger UI is enabled at /swagger.

## Workflows

- .github/workflows/infra.yaml
  - Runs Terraform fmt, init, validate, plan, apply
  - Triggered by workflow_dispatch and pushes to main for infra/terraform changes
  - Uses workflow concurrency guard to prevent overlapping apply runs
- .github/workflows/app.yaml
  - Builds the API
  - Builds and pushes image to ACR using Azure RBAC (no admin credentials)
  - Updates Container App image
  - Resolves resources by deterministic stack tag (`inventory-api-final`) to avoid selecting the wrong resources in shared class resource groups
  - Supports manual workflow_dispatch overrides: `acr_name` and `container_app_name`

## Local Commands

Run API:

```bash
cd src/InventoryApi
dotnet restore
dotnet build
dotnet run
```

Run Terraform:

```bash
cd infra/terraform
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```
