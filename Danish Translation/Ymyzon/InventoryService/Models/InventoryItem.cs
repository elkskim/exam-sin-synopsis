namespace InventoryService.Models;

public class InventoryItem
{
    public string ProductName { get; set; } = string.Empty;
    public int AvailableQuantity { get; set; }
    public DateTime LastUpdated { get; set; }
}

