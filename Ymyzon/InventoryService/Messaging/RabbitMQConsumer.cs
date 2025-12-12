namespace InventoryService.Messaging;

using System.Text;
using System.Text.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using InventoryService.Services;

public class RabbitMQConsumer : BackgroundService
{
    private IConnection? _connection;
    private IChannel? _channel;
    private readonly string _queueName = "order-queue";
    private readonly InventoryManager _inventoryManager;
    private readonly ILogger<RabbitMQConsumer> _logger;
    private readonly string _hostname;

    public RabbitMQConsumer(InventoryManager inventoryManager, ILogger<RabbitMQConsumer> logger, IConfiguration configuration)
    {
        _inventoryManager = inventoryManager;
        _logger = logger;
        _hostname = configuration.GetValue<string>("RabbitMQ:HostName") ?? "localhost";
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        stoppingToken.ThrowIfCancellationRequested();

        try
        {
            // Initialize connection
            var factory = new ConnectionFactory { HostName = _hostname };
            _connection = await factory.CreateConnectionAsync();
            _channel = await _connection.CreateChannelAsync();

            // Declare the queue
            await _channel.QueueDeclareAsync(
                queue: _queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            _logger.LogInformation("RabbitMQ Consumer initialized and connected to {Hostname}", _hostname);

            var consumer = new AsyncEventingBasicConsumer(_channel);

            consumer.ReceivedAsync += async (model, ea) =>
            {
                try
                {
                    var body = ea.Body.ToArray();
                    var message = Encoding.UTF8.GetString(body);
                    _logger.LogInformation("[Consumer] Received: {Message}", message);

                    // Deserialize the order message
                    var orderData = JsonSerializer.Deserialize<OrderMessage>(message);

                    if (orderData != null)
                    {
                        // Process the order - deduct inventory
                        var success = _inventoryManager.DeductInventory(orderData.ProductName, orderData.Quantity);

                        if (success)
                        {
                            _logger.LogInformation($"Order {orderData.Id} processed successfully");
                            await _channel!.BasicAckAsync(deliveryTag: ea.DeliveryTag, multiple: false);
                        }
                        else
                        {
                            _logger.LogWarning($"Order {orderData.Id} failed - insufficient inventory");
                            await _channel!.BasicNackAsync(deliveryTag: ea.DeliveryTag, multiple: false, requeue: false);
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing message");
                    await _channel!.BasicNackAsync(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
                }
            };

            await _channel.BasicConsumeAsync(queue: _queueName, autoAck: false, consumer: consumer);

            // Keep running until cancellation
            await Task.Delay(Timeout.Infinite, stoppingToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in RabbitMQ Consumer");
        }
    }

    public override void Dispose()
    {
        _channel?.Dispose();
        _connection?.Dispose();
        base.Dispose();
    }

    private class OrderMessage
    {
        public int Id { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal Price { get; set; }
        public DateTime OrderDate { get; set; }
    }
}

