using OrderService.Messaging;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// Get RabbitMQ hostname from configuration (defaults to localhost)
var rabbitMqHost = builder.Configuration.GetValue<string>("RabbitMQ:HostName") ?? "localhost";

// Register RabbitMQ Publisher as singleton
builder.Services.AddSingleton(sp => new RabbitMQPublisher(rabbitMqHost));

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.MapControllers();

app.Run();

