# Inventory API

Cloud-native inventory service built with ASP.NET Core and designed for Azure deployment.

## Repository Structure

```text
src/
  InventoryApi/

infra/
  terraform/
    main.tf
    providers.tf
    variables.tf
    outputs.tf
    versions.tf

.github/
  workflows/

docs/
```

## Planned Architecture

- **API**: ASP.NET Core Web API (`src/InventoryApi`)
- **Container Runtime**: Azure Container Apps
- **Container Registry**: Azure Container Registry (ACR)
- **Data Store**: Azure Cosmos DB (Serverless)
- **Configuration**: Azure App Configuration
- **Observability**: Azure Application Insights + Log Analytics
- **Infrastructure as Code**: Terraform (`infra/terraform`)
- **CI/CD Security**: GitHub Actions with Azure OIDC authentication (no client secrets)

## Security Direction

- GitHub Actions authenticates to Azure using OIDC (`azure/login@v2`)
- No client secrets in workflows
- No connection strings committed to source control
- Application code is prepared for future Managed Identity and `DefaultAzureCredential` adoption
- RBAC authentication will be used where available

## Local Development

```bash
cd src/InventoryApi
dotnet restore
dotnet run
```

Health endpoint:

```text
GET /health
```
