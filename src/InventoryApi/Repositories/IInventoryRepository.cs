using InventoryApi.Models;

namespace InventoryApi.Repositories;

public interface IInventoryRepository
{
    Task<IReadOnlyCollection<InventoryItem>> GetAllAsync(CancellationToken cancellationToken = default);

    Task<InventoryItem?> GetByIdAsync(string id, CancellationToken cancellationToken = default);

    Task<InventoryItem> CreateAsync(InventoryItem item, CancellationToken cancellationToken = default);

    Task<bool> UpdateAsync(string id, InventoryItem item, CancellationToken cancellationToken = default);

    Task<bool> DeleteAsync(string id, CancellationToken cancellationToken = default);
}
