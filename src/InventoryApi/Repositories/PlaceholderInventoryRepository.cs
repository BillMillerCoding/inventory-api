using InventoryApi.Models;
using System.Collections.Concurrent;

namespace InventoryApi.Repositories;

public class PlaceholderInventoryRepository : IInventoryRepository
{
    private readonly ConcurrentDictionary<string, InventoryItem> _items = new(StringComparer.OrdinalIgnoreCase);

    public Task<IReadOnlyCollection<InventoryItem>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var result = _items.Values
            .OrderBy(item => item.Name)
            .ToArray();

        return Task.FromResult<IReadOnlyCollection<InventoryItem>>(result);
    }

    public Task<InventoryItem?> GetByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        _items.TryGetValue(id, out var item);
        return Task.FromResult(item);
    }

    public Task<InventoryItem> CreateAsync(InventoryItem item, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(item.Id))
        {
            item.Id = Guid.NewGuid().ToString("N");
        }

        _items[item.Id] = item;
        return Task.FromResult(item);
    }

    public Task<bool> UpdateAsync(string id, InventoryItem item, CancellationToken cancellationToken = default)
    {
        if (!_items.ContainsKey(id))
        {
            return Task.FromResult(false);
        }

        item.Id = id;
        _items[id] = item;
        return Task.FromResult(true);
    }

    public Task<bool> DeleteAsync(string id, CancellationToken cancellationToken = default)
    {
        var removed = _items.TryRemove(id, out _);
        return Task.FromResult(removed);
    }
}
