namespace InventoryApi.Models;

public class InventoryItem
{
    public Guid Id { get; set; }

    public string Sku { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public int Quantity { get; set; }
}
