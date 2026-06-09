using Azure.Core;
using Azure.Identity;
using InventoryApi.Repositories;

namespace InventoryApi.DependencyInjection;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddInventoryApiServices(this IServiceCollection services)
    {
        services.AddSingleton<TokenCredential>(_ => new DefaultAzureCredential());
        services.AddSingleton<IInventoryRepository, PlaceholderInventoryRepository>();

        return services;
    }
}
