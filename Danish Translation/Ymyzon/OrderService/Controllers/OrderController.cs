namespace OrderService.Controllers;

using Microsoft.AspNetCore.Mvc;
using OrderService.Models;
using OrderService.Messaging;

[ApiController]
[Route("api/[controller]")]
public class OrderController : ControllerBase
{
    private readonly RabbitMQPublisher _publisher;
    private readonly ILogger<OrderController> _logger;

    public OrderController(RabbitMQPublisher publisher, ILogger<OrderController> logger)
    {
        _publisher = publisher;
        _logger = logger;
    }

    [HttpPost("create")]
    public async Task<IActionResult> CreateOrder([FromBody] Order order)
    {
        try
        {
            // Set order date
            order.OrderDate = DateTime.UtcNow;

            // Publish to RabbitMQ
            await _publisher.PublishOrderMessageAsync(new
            {
                order.Id,
                order.ProductName,
                order.Quantity,
                order.Price,
                order.OrderDate
            });

            _logger.LogInformation($"Order {order.Id} created and published to queue");

            return Ok(new
            {
                Message = "Order created successfully!",
                OrderId = order.Id,
                ProductName = order.ProductName,
                Quantity = order.Quantity
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating order");
            return StatusCode(500, new { Error = "Failed to create order" });
        }
    }

    [HttpGet("health")]
    public IActionResult Health()
    {
        return Ok(new { Status = "Healthy", Service = "OrderService" });
    }
}