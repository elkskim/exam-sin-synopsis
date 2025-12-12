namespace InventoryService.Controllers;

using Microsoft.AspNetCore.Mvc;
using InventoryService.Services;

[ApiController]
[Route("api/[controller]")]
public class InventoryController : ControllerBase
{
    private readonly InventoryManager _inventoryManager;
    private readonly ILogger<InventoryController> _logger;

    public InventoryController(InventoryManager inventoryManager, ILogger<InventoryController> logger)
    {
        _inventoryManager = inventoryManager;
        _logger = logger;
    }

    [HttpGet("{productName}")]
    public IActionResult GetInventory(string productName)
    {
        var item = _inventoryManager.GetInventory(productName);

        if (item == null)
        {
            return NotFound(new { Error = $"Product {productName} not found" });
        }

        return Ok(item);
    }

    [HttpGet("all")]
    public IActionResult GetAllInventory()
    {
        var inventory = _inventoryManager.GetAllInventory();
        return Ok(inventory);
    }

    [HttpGet("health")]
    public IActionResult Health()
    {
        return Ok(new { Status = "Healthy", Service = "InventoryService" });
    }
}

