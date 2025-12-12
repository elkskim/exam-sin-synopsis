# Quick Command Reference - .NET CI/CD Project

## Initial Setup Commands

### Create the project structure
```cmd
mkdir Ymyzon
cd Ymyzon

REM Create OrderService
dotnet new webapi -n OrderService

REM Create InventoryService  
dotnet new webapi -n InventoryService

REM Create solution file (optional but recommended)
dotnet new sln -n Ymyzon
dotnet sln add OrderService\OrderService.csproj
dotnet sln add InventoryService\InventoryService.csproj
```

### Add RabbitMQ packages
```cmd
cd OrderService
dotnet add package RabbitMQ.Client
cd ..

cd InventoryService
dotnet add package RabbitMQ.Client
cd ..
```

## RabbitMQ Commands

### Start RabbitMQ (first time - with management UI)
```cmd
docker run -d --name rabbitmq ^
  -p 5672:5672 ^
  -p 15672:15672 ^
  rabbitmq:3-management
```

### Access RabbitMQ Management UI
http://localhost:15672
- Username: guest
- Password: guest

### Stop/Start/Remove RabbitMQ
```cmd
docker stop rabbitmq
docker start rabbitmq
docker rm rabbitmq
```

## Local Testing (Before Docker)

### Run services locally
```cmd
REM Terminal 1 - RabbitMQ
docker run -d -p 5672:5672 -p 15672:15672 rabbitmq:3-management

REM Terminal 2 - InventoryService
cd InventoryService
dotnet run

REM Terminal 3 - OrderService
cd OrderService
dotnet run
```

### Test the endpoints
```cmd
REM Create an order (adjust port if needed)
curl -X POST http://localhost:5000/orders ^
  -H "Content-Type: application/json" ^
  -d "{\"orderId\": \"123\", \"skus\": [{\"sku\": \"ITEM-001\", \"quantity\": 2}]}"

REM Check inventory
curl http://localhost:5001/inventory/ITEM-001
```

## Docker Build Commands (Manual Deployment)

### Build Docker images manually
```cmd
REM Build OrderService image
cd OrderService
docker build -t orderservice:latest .
cd ..

REM Build InventoryService image
cd InventoryService
docker build -t inventoryservice:latest .
cd ..
```

### Run containers manually (Manual Deployment - Time This!)
```cmd
REM 1. Start RabbitMQ
docker run -d --name rabbitmq --network ymyzon-network -p 5672:5672 rabbitmq:3-management

REM 2. Start InventoryService
docker run -d --name inventoryservice ^
  --network ymyzon-network ^
  -e RABBITMQ_HOST=rabbitmq ^
  -p 5001:80 ^
  inventoryservice:latest

REM 3. Start OrderService
docker run -d --name orderservice ^
  --network ymyzon-network ^
  -e RABBITMQ_HOST=rabbitmq ^
  -p 5000:80 ^
  orderservice:latest
```

### Create Docker network
```cmd
docker network create ymyzon-network
```

### Manual deployment cleanup (between attempts)
```cmd
docker stop orderservice inventoryservice rabbitmq
docker rm orderservice inventoryservice rabbitmq
docker network rm ymyzon-network
```

## Docker Compose Commands (Automated Deployment)

### Start everything with Docker Compose
```cmd
docker-compose up -d
```

### Stop everything
```cmd
docker-compose down
```

### Rebuild and restart
```cmd
docker-compose up -d --build
```

### View logs
```cmd
docker-compose logs -f
docker-compose logs -f orderservice
docker-compose logs -f inventoryservice
```

## Useful Docker Commands

### View running containers
```cmd
docker ps
```

### View all containers (including stopped)
```cmd
docker ps -a
```

### View logs for a container
```cmd
docker logs orderservice
docker logs -f orderservice
```

### Execute command in container
```cmd
docker exec -it orderservice sh
```

### Remove all stopped containers
```cmd
docker container prune
```

### Remove all images
```cmd
docker image prune -a
```

## GitHub Repository Setup

### Initialize Git
```cmd
cd Ymyzon
git init
git add .
git commit -m "Initial commit"
```

### Create repository on GitHub, then:
```cmd
git remote add origin https://github.com/YOUR_USERNAME/ymyzon.git
git branch -M main
git push -u origin main
```

## Measurement Tracking

### Start timer before each deployment
```cmd
REM Use your phone or:
echo %time%
REM ... do deployment ...
echo %time%
REM Calculate difference
```

### Track errors
- Screenshot any errors
- Copy error messages to MEASUREMENTS.md
- Note which step failed

## Quick Troubleshooting

### Services can't connect to RabbitMQ
```cmd
REM Check if RabbitMQ is running
docker ps | findstr rabbitmq

REM Check network connectivity
docker network inspect ymyzon-network

REM Check logs
docker logs rabbitmq
```

### Port already in use
```cmd
REM Find what's using the port
netstat -ano | findstr :5000

REM Kill the process (use PID from above)
taskkill /PID <PID> /F
```

### Docker build fails
```cmd
REM Clear Docker cache
docker builder prune

REM Rebuild without cache
docker build --no-cache -t orderservice:latest .
```

## Pro Tips

1. **Always document your time** - Start a timer before each deployment
2. **Take screenshots** - Especially of errors or success messages
3. **Use consistent naming** - Makes tracking easier
4. **Test incrementally** - Don't wait until everything is built
5. **Commit often** - Easy to rollback if something breaks

## Time Tracking Template

Copy this for each deployment attempt:

```
DEPLOYMENT ATTEMPT #X - [Manual/Automated]
Start Time: [TIME]
Steps:
  1. [Step description] - [Time taken] - [Errors: Y/N]
  2. [Step description] - [Time taken] - [Errors: Y/N]
  ...
End Time: [TIME]
Total Time: [MINUTES]
Total Errors: [COUNT]
Notes: [Any observations]
```

