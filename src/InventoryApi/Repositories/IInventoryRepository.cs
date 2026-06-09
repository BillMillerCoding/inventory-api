using InventoryApi.Models;

namespace InventoryApi.Repositories;

public interface IInventoryRepository
{
    Task<IReadOnlyCollection<InventoryItem>> GetAllAsync(CancellationToken cancellationToken = default);

    Task<InventoryItem?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
}
