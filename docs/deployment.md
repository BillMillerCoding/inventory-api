# Deployment Guide

This project uses two GitHub Actions workflows for end-to-end deployment with OIDC and Terraform.

## 1) Infrastructure Workflow (infra.yaml)

File: .github/workflows/infra.yaml

Purpose:

- Deploy all required Azure infrastructure into existing resource group rg-inventory-final
- Run Terraform quality checks and deployment in CI

Triggers:

- workflow_dispatch
- push to main when files under infra/terraform change

Execution flow:

1. Checkout repository
2. Azure login using OIDC (azure/login@v2)
3. Terraform fmt -check
4. Terraform init
5. Terraform validate
6. Terraform plan
7. Terraform apply -auto-approve

Terraform deploys:

- Azure Container Registry
- Log Analytics Workspace
- Application Insights
- Container Apps Environment
- Container App (system-assigned managed identity)
- Cosmos DB (Serverless SQL API, database, container)
- App Configuration

## 2) Application Workflow (app.yaml)

File: .github/workflows/app.yaml

Purpose:

- Build and validate the ASP.NET Core API
- Build and push a new image to ACR using Azure RBAC
- Update Azure Container App to use the new image

Triggers:

- workflow_dispatch
- push to main when files under src/InventoryApi change

Execution flow:

1. Checkout repository
2. Azure login using OIDC (azure/login@v2)
3. Dotnet restore/build
4. Resolve ACR and Container App names from rg-inventory-final
5. Build and push image via az acr build
6. Update container app image via az containerapp update

Resource resolution behavior:

- Default: workflow discovers resources by `tags.stack=inventory-api-final`
- If resolution is ambiguous, workflow fails fast and prints matching names
- Manual override inputs are available on `workflow_dispatch`:
  - `acr_name`
  - `container_app_name`

## OIDC Authentication Model

Both workflows use short-lived federated credentials through GitHub OIDC.

- Required GitHub repository variables:
  - AZURE_CLIENT_ID
  - AZURE_TENANT_ID
  - AZURE_SUBSCRIPTION_ID
- No client secrets are used
- No passwords are used
- No connection strings are stored in GitHub

## End-to-End Deployment Sequence

1. Run infra workflow to provision or update Azure resources.
2. Run app workflow to build, push, and deploy the latest API image.
3. Verify API health endpoint and Swagger endpoint on the Container App URL.

Notes for repeated class demos:

- Infra workflow uses concurrency control to avoid overlapping Terraform applies.
- App workflow uses concurrency control to avoid image/update races on the same branch.
