using InventoryService.Services;
using InventoryService.Messaging;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// Register InventoryManager as singleton (shared state)
builder.Services.AddSingleton<InventoryManager>();

// Register RabbitMQ Consumer as hosted service (background worker)
builder.Services.AddHostedService<RabbitMQConsumer>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.MapControllers();

app.Run();

