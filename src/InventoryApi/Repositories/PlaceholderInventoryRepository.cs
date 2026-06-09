using InventoryApi.Models;

namespace InventoryApi.Repositories;

public class PlaceholderInventoryRepository : IInventoryRepository
{
    public Task<IReadOnlyCollection<InventoryItem>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return Task.FromResult<IReadOnlyCollection<InventoryItem>>(Array.Empty<InventoryItem>());
    }

    public Task<InventoryItem?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return Task.FromResult<InventoryItem?>(null);
    }
}
