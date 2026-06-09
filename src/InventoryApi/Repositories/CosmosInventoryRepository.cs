using Azure.Core;
using InventoryApi.Models;
using Microsoft.Azure.Cosmos;
using System.Net;

namespace InventoryApi.Repositories;

public class CosmosInventoryRepository : IInventoryRepository
{
    private readonly Container _container;

    public CosmosInventoryRepository(CosmosClient cosmosClient, IConfiguration configuration)
    {
        var database = configuration["COSMOS_DATABASE"] ?? "inventorydb";
        var container = configuration["COSMOS_CONTAINER"] ?? "items";
        _container = cosmosClient.GetContainer(database, container);
    }

    public async Task<IReadOnlyCollection<InventoryItem>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var query = new QueryDefinition("SELECT * FROM c ORDER BY c.name");
        var results = new List<InventoryItem>();

        using var feed = _container.GetItemQueryIterator<InventoryItem>(query);
        while (feed.HasMoreResults)
        {
            var batch = await feed.ReadNextAsync(cancellationToken);
            results.AddRange(batch);
        }

        return results;
    }

    public async Task<InventoryItem?> GetByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        try
        {
            var response = await _container.ReadItemAsync<InventoryItem>(id, new PartitionKey(id), cancellationToken: cancellationToken);
            return response.Resource;
        }
        catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }
    }

    public async Task<InventoryItem> CreateAsync(InventoryItem item, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(item.Id))
        {
            item.Id = Guid.NewGuid().ToString("N");
        }

        var response = await _container.CreateItemAsync(item, new PartitionKey(item.Id), cancellationToken: cancellationToken);
        return response.Resource;
    }

    public async Task<bool> UpdateAsync(string id, InventoryItem item, CancellationToken cancellationToken = default)
    {
        try
        {
            item.Id = id;
            await _container.ReplaceItemAsync(item, id, new PartitionKey(id), cancellationToken: cancellationToken);
            return true;
        }
        catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
        {
            return false;
        }
    }

    public async Task<bool> DeleteAsync(string id, CancellationToken cancellationToken = default)
    {
        try
        {
            await _container.DeleteItemAsync<InventoryItem>(id, new PartitionKey(id), cancellationToken: cancellationToken);
            return true;
        }
        catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
        {
            return false;
        }
    }
}
