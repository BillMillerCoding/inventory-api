using Azure.Core;
using Azure.Identity;
using InventoryApi.Repositories;
using Microsoft.Azure.Cosmos;

namespace InventoryApi.DependencyInjection;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddInventoryApiServices(this IServiceCollection services, IConfiguration configuration)
    {
        var credential = new DefaultAzureCredential();
        services.AddSingleton<TokenCredential>(_ => credential);

        var cosmosEndpoint = configuration["COSMOS_ENDPOINT"] ?? throw new InvalidOperationException("COSMOS_ENDPOINT is not configured.");
        var cosmosClient = new CosmosClient(cosmosEndpoint, credential, new CosmosClientOptions
        {
            SerializerOptions = new CosmosSerializationOptions
            {
                PropertyNamingPolicy = CosmosPropertyNamingPolicy.CamelCase
            }
        });
        services.AddSingleton(cosmosClient);
        services.AddSingleton<IInventoryRepository, CosmosInventoryRepository>();

        return services;
    }
}
