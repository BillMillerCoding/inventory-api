using InventoryApi.Repositories;

namespace InventoryApi.DependencyInjection;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddInventoryApiServices(this IServiceCollection services)
    {
        services.AddSingleton<IInventoryRepository, PlaceholderInventoryRepository>();

        return services;
    }
}
