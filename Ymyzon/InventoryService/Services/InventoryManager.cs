namespace InventoryService.Services;

using InventoryService.Models;

public class InventoryManager
{
    private readonly Dictionary<string, InventoryItem> _inventory = new();
    private readonly ILogger<InventoryManager> _logger;

    public InventoryManager(ILogger<InventoryManager> logger)
    {
        _logger = logger;

        // Seed some initial inventory
        _inventory["Laptop"] = new InventoryItem { ProductName = "Laptop", AvailableQuantity = 100, LastUpdated = DateTime.UtcNow };
        _inventory["Mouse"] = new InventoryItem { ProductName = "Mouse", AvailableQuantity = 500, LastUpdated = DateTime.UtcNow };
        _inventory["Keyboard"] = new InventoryItem { ProductName = "Keyboard", AvailableQuantity = 300, LastUpdated = DateTime.UtcNow };
        _inventory["Monitor"] = new InventoryItem { ProductName = "Monitor", AvailableQuantity = 150, LastUpdated = DateTime.UtcNow };
    }

    public bool DeductInventory(string productName, int quantity)
    {
        if (_inventory.TryGetValue(productName, out var item))
        {
            if (item.AvailableQuantity >= quantity)
            {
                item.AvailableQuantity -= quantity;
                item.LastUpdated = DateTime.UtcNow;
                _logger.LogInformation($"Deducted {quantity} from {productName}. New quantity: {item.AvailableQuantity}");
                return true;
            }
            else
            {
                _logger.LogWarning($"Insufficient inventory for {productName}. Requested: {quantity}, Available: {item.AvailableQuantity}");
                return false;
            }
        }
        else
        {
            _logger.LogWarning($"Product {productName} not found in inventory");
            return false;
        }
    }

    public InventoryItem? GetInventory(string productName)
    {
        return _inventory.GetValueOrDefault(productName);
    }

    public Dictionary<string, InventoryItem> GetAllInventory()
    {
        return _inventory;
    }
}

