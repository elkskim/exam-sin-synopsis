namespace OrderService.Messaging;

using System.Text;
using System.Text.Json;
using RabbitMQ.Client;

public class RabbitMQPublisher : IAsyncDisposable
{
    private IConnection? _connection;
    private IChannel? _channel;
    private readonly string _queueName = "order-queue";
    private readonly string _hostname;
    private bool _initialized = false;
    private readonly SemaphoreSlim _initLock = new SemaphoreSlim(1, 1);

    public RabbitMQPublisher(string hostname = "localhost")
    {
        _hostname = hostname;
    }

    private async Task EnsureInitializedAsync()
    {
        if (_initialized) return;

        await _initLock.WaitAsync();
        try
        {
            if (_initialized) return; // Double-check after acquiring lock

            var factory = new ConnectionFactory { HostName = _hostname };
            _connection = await factory.CreateConnectionAsync();
            _channel = await _connection.CreateChannelAsync();

            // Declare the queue (idempotent - safe to call multiple times)
            await _channel.QueueDeclareAsync(
                queue: _queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            _initialized = true;
            Console.WriteLine($"[Publisher] Connected to RabbitMQ at {_hostname}");
        }
        finally
        {
            _initLock.Release();
        }
    }

    public async Task PublishOrderMessageAsync(object orderMessage)
    {
        await EnsureInitializedAsync();

        var json = JsonSerializer.Serialize(orderMessage);
        var body = Encoding.UTF8.GetBytes(json);

        var properties = new BasicProperties
        {
            Persistent = true // Survive broker restarts
        };

        await _channel!.BasicPublishAsync(
            exchange: string.Empty,
            routingKey: _queueName,
            mandatory: false,
            basicProperties: properties,
            body: body
        );

        Console.WriteLine($"[Publisher] Sent: {json}");
    }

    public async ValueTask DisposeAsync()
    {
        if (_channel != null) await _channel.CloseAsync();
        if (_connection != null) await _connection.CloseAsync();
        _initLock.Dispose();
    }
}

