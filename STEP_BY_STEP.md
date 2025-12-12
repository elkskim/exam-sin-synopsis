# LET'S KEEP TRACK OF STEPS

## MANUAL DEPLOYMENT STEPS

Manual Deployment Steps:
1. Start RabbitMQ container manually
    - docker run rabbitmq command
    - Configure ports, credentials
2. Build Order-system
    - npm install / dotnet restore
    - Configure RabbitMQ connection string
3. Build Inventory-system
    - npm install / dotnet restore
    - Configure RabbitMQ connection string
4. Start Order-system container
5. Start Inventory-system container
6. Test: Create order, verify inventory updates
7. Document time and any errors

[ ] Repeat 5 times, track metrics each time


## AUTOMATED DEPLOYMENT STEPS

GitHub Actions Workflow:
- Trigger: Push to main branch
- Step 1: Run tests (if any)
- Step 2: Build Docker images for both services
- Step 3: Push images to registry
- Step 4: Deploy using Docker Compose
    - Compose file defines all 3 services
    - One command: docker-compose up

Docker Compose handles:
- RabbitMQ container
- Order-system container
- Inventory-system container
- Network configuration
- Environment variables


## TECHNOLOGY STACK

**Language/Framework:** .NET 8 / C# (ASP.NET Core Web API)

**RabbitMQ Client:** RabbitMQ.Client NuGet package

**Project Structure:**
```
Ymyzon/
├── OrderService/          # ASP.NET Core Web API
│   ├── OrderService.csproj
│   ├── Program.cs
│   ├── Controllers/OrderController.cs
│   ├── Services/RabbitMQPublisher.cs
│   └── Dockerfile
├── InventoryService/      # ASP.NET Core Worker Service or Web API
│   ├── InventoryService.csproj
│   ├── Program.cs
│   ├── Services/RabbitMQConsumer.cs
│   ├── Services/InventoryManager.cs
│   └── Dockerfile
├── docker-compose.yml
└── .github/
    └── workflows/
        └── deploy.yml
```


## IMPLEMENTATION STEPS (DO THESE IN ORDER!)

### Phase 1: Build Simple Services (Manual First) - 4 hours ✅ COMPLETED!
[✓] 1. Create OrderService Web API
    - `dotnet new webapi -n OrderService` ✅
    - Add RabbitMQ.Client package ✅
    - Create POST /api/order/create endpoint ✅
    - Implement RabbitMQPublisher with queue declaration ✅
    - Register as singleton in DI ✅
    - Health endpoint added ✅

[✓] 2. Create InventoryService
    - `dotnet new webapi -n InventoryService` ✅
    - Add RabbitMQ.Client package ✅
    - Implement RabbitMQConsumer as BackgroundService ✅
    - Create InventoryManager with in-memory storage ✅
    - Create GET /api/inventory endpoints ✅
    - Register services in DI ✅
    - Health endpoint added ✅

[⏭️] 3. TEST SERVICES LOCALLY - NEXT STEP!
    - See Ymyzon/TESTING_GUIDE.md for detailed instructions
    - Start RabbitMQ container
    - Run both services with dotnet run
    - Create orders via HTTP requests
    - Verify inventory updates in real-time
    - Document that it works!
    - Add RabbitMQ.Client package
    - Implement RabbitMQ consumer (background service)
    - Create GET /inventory/{sku} endpoint
    - In-memory inventory dictionary
    - Test locally without Docker

[ ] 3. Test services together locally
    - Run RabbitMQ in Docker: `docker run -d -p 5672:5672 -p 15672:15672 rabbitmq:3-management`
    - Run both services with dotnet run
    - Create order, verify inventory updates
    - Document all steps and time

### Phase 2: Manual Deployment (5 deployments) - 3 hours
[ ] 4. Create Dockerfiles for both services
[ ] 5. Perform manual deployment #1
    - Start RabbitMQ container
    - Build Docker images manually
    - Run containers manually
    - Test functionality
    - Document: time, steps, errors
[ ] 6. Repeat deployments #2-5
    - Track metrics in MEASUREMENTS.md
    - Note any variations or issues

### Phase 3: Automated CI/CD Setup - 4 hours
[ ] 7. Create docker-compose.yml
    - Define all 3 services
    - Configure networks
    - Set environment variables
[ ] 8. Create GitHub Actions workflow
    - Build both services
    - Push to GitHub Container Registry
    - Deploy using docker-compose
[ ] 9. Test the automated pipeline

### Phase 4: Automated Deployment (5 deployments) - 2 hours
[ ] 10. Perform 5 automated deployments
    - Push commits to trigger pipeline
    - Track metrics in MEASUREMENTS.md
    - Compare to manual deployments

### Phase 5: Analysis & Writing - 8 hours
[ ] 11. Fill in all measurement tables
[ ] 12. Create comparison graphs/charts
[ ] 13. Write the synopsis (use main.tex)
[ ] 14. Review and polish


## .NET SPECIFIC NOTES

**RabbitMQ Connection:**
```csharp
var factory = new ConnectionFactory { 
    HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
    UserName = "guest",
    Password = "guest"
};
```

**Keep it MINIMAL:**
- No Entity Framework (use in-memory Dictionary)
- No authentication/authorization
- No complex validation
- Focus on the CI/CD comparison!

**Dockerfile Pattern:**
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["OrderService.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OrderService.dll"]
```


## MEASUREMENT TRACKING

**Use MEASUREMENTS.md to track all your data!**
- Fill in tables as you go
- Don't rely on memory
- Take screenshots of errors
- Note timestamps

