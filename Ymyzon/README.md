# Ymyzon - Microservices Order & Inventory System

A demonstration microservices system for CI/CD pipeline comparison, featuring order processing and inventory management with RabbitMQ messaging.

---

## 📋 Project Overview

**Purpose:** CI/CD Pipeline Analysis for SIN Synopsis  
**Architecture:** Microservices with message-based communication  
**Tech Stack:** .NET 9, C#, RabbitMQ, Docker

### Components

1. **OrderService** - REST API for order creation, publishes to RabbitMQ
2. **InventoryService** - Consumes orders, manages inventory
3. **RabbitMQ** - Message broker for async communication

---

## 🚀 Quick Start

### Prerequisites
- Docker Desktop (running)
- .NET 9 SDK
- PowerShell, Git Bash, or CMD

### Start Everything (One Command)

**PowerShell (Recommended):**
```powershell
cd Scripts
.\start-all.ps1
```

**Git Bash/Linux:**
```bash
cd Scripts
bash start-all.sh
```

This will start RabbitMQ, InventoryService, and OrderService, then run health checks.

### Run Tests

```powershell
cd Scripts
# Health checks
.\test-services.ps1

# End-to-end order test
.\test-create-order.ps1
```

**Expected Result:** Order created → Message sent → Inventory decreased by 5

---

## 📖 Documentation

- **README.md** (this file) - Project overview
- **QUICK_START.md** - Detailed startup and testing guide
- **MANUAL_STARTUP_GUIDE.md** - Step-by-step manual instructions
- **TROUBLESHOOTING.md** - Common issues and solutions

---

## 🏗️ Architecture

```
Client (HTTP)
    ↓
OrderService (Port 5194)
    ↓ Publishes message
RabbitMQ (Ports 5672, 15672)
    ↓ Consumes message
InventoryService (Port 5219)
    ↓ Updates inventory
In-Memory Database
```

### Message Flow

1. Client sends POST request to OrderService
2. OrderService publishes order to RabbitMQ queue
3. InventoryService consumes message from queue
4. Inventory is automatically updated
5. Message is acknowledged and removed from queue

---

## 🔌 API Endpoints

### OrderService (http://localhost:5194)

```http
POST /api/order/create
Content-Type: application/json

{
  "id": 1,
  "productName": "Laptop",
  "quantity": 5,
  "price": 1299.99
}
```

```http
GET /api/order/health
```

### InventoryService (http://localhost:5219)

```http
GET /api/inventory/all
GET /api/inventory/{productName}
GET /api/inventory/health
```

### RabbitMQ Management

**URL:** http://localhost:15672  
**Credentials:** guest / guest

---

## 🧪 Testing

### Available Scripts

| Script | Purpose |
|--------|---------|
| `start-all.ps1` / `start-all.sh` | Start all services |
| `test-services.ps1` / `test-services.sh` | Health checks |
| `test-create-order.ps1` / `test-create-order.sh` | End-to-end test |
| `test-manual.sh` | File-based testing |
| `start-background.sh` | Background services |
| `stop-services.sh` | Stop background services |

### Test Verification

**Success indicators:**
- ✅ Services respond to health checks
- ✅ Initial inventory: Laptop=100, Mouse=500, Keyboard=300, Monitor=150
- ✅ Order creation returns success
- ✅ Inventory decreases by order quantity
- ✅ Console logs show message flow

---

## 🛠️ Technology Stack

- **.NET 9** - Modern C# microservices
- **ASP.NET Core** - Web API framework
- **RabbitMQ.Client v7** - Async message broker client
- **Docker** - Container platform
- **RabbitMQ** - Message broker

### Key Patterns

- **Microservices Architecture** - Independent, loosely coupled services
- **Event-Driven Communication** - Async messaging via RabbitMQ
- **REST APIs** - Synchronous client communication
- **Background Services** - .NET hosted service for message consumption
- **Dependency Injection** - .NET DI container
- **Async/Await** - Modern async patterns throughout

---

## 📁 Project Structure

```
Ymyzon/
├── OrderService/              # Order creation service
│   ├── Controllers/           # REST API controllers
│   ├── Messaging/             # RabbitMQ publisher
│   ├── Models/                # Data models
│   └── Program.cs             # Service configuration
│
├── InventoryService/          # Inventory management service
│   ├── Controllers/           # REST API controllers
│   ├── Messaging/             # RabbitMQ consumer
│   ├── Services/              # Business logic
│   ├── Models/                # Data models
│   └── Program.cs             # Service configuration
│
├── README.md                  # This file
├── QUICK_START.md             # Detailed guide
├── MANUAL_STARTUP_GUIDE.md    # Manual setup
├── TROUBLESHOOTING.md         # Issue resolution
│
└── start-all.*                # Startup scripts
    test-*.* (scripts)         # Test scripts
```

---

## 🐛 Common Issues

### Services Won't Start
- **Check:** Docker Desktop is running
- **Fix:** `docker ps` to verify

### Test Fails (Inventory Mismatch)
- **Cause:** Old messages in RabbitMQ queue
- **Fix:** Clear queue at http://localhost:15672 or restart services

### Port Already in Use
- **Fix (PowerShell):**
  ```powershell
  Get-Process -Id (Get-NetTCPConnection -LocalPort 5219).OwningProcess | Stop-Process -Force
  ```

**For detailed solutions:** See `TROUBLESHOOTING.md`

---

## 📊 Synopsis Context

This project demonstrates:

1. **Service Scoping & Bounded Context**
   - Order domain (OrderService)
   - Inventory domain (InventoryService)

2. **Service Design & Architecture**
   - RESTful APIs
   - Event-driven messaging
   - Async communication

3. **Communication Technologies**
   - REST for synchronous requests
   - RabbitMQ for async operations

4. **Deployment Readiness**
   - Docker-compatible
   - Automated testing
   - CI/CD pipeline ready

---

## 🎯 Project Phases

- ✅ **Phase 1:** Service Implementation (Complete)
- ⏭️ **Phase 2:** Dockerization
- ⏭️ **Phase 3:** Manual Deployment Testing
- ⏭️ **Phase 4:** CI/CD Pipeline (GitHub Actions)
- ⏭️ **Phase 5:** Synopsis Writing

---

## 📝 License & Context

**Course:** System Integration (SIN)  
**Purpose:** Exam synopsis demonstrating CI/CD pipeline comparison  
**Date:** December 2025

---

## 🚀 Next Steps

1. Start services: `cd Scripts && .\start-all.ps1`
2. Run tests: `.\test-create-order.ps1`
3. Verify message flow in console logs
4. See **QUICK_START.md** for detailed instructions

**The services are fully functional and ready for testing!**
# Ymyzon Services Startup Script
# PowerShell version - more reliable on Windows than Git Bash

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Ymyzon Microservices System" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "[1/3] Checking Docker..." -ForegroundColor Yellow
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
        exit 1
    }
    Write-Host "Docker is running!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not installed or not running." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Start RabbitMQ
Write-Host "[2/3] Starting RabbitMQ..." -ForegroundColor Yellow
$rabbitRunning = docker ps --format "{{.Names}}" | Select-String "^rabbitmq$"
if ($rabbitRunning) {
    Write-Host "RabbitMQ already running" -ForegroundColor Green
} else {
    $rabbitExists = docker ps -a --format "{{.Names}}" | Select-String "^rabbitmq$"
    if ($rabbitExists) {
        docker start rabbitmq | Out-Null
        Write-Host "RabbitMQ container started" -ForegroundColor Green
    } else {
        Write-Host "Creating new RabbitMQ container..." -ForegroundColor Yellow
        docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management | Out-Null
        Write-Host "RabbitMQ container created" -ForegroundColor Green
    }
}

Write-Host "Waiting for RabbitMQ to initialize (15 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15
Write-Host "RabbitMQ ready!" -ForegroundColor Green
Write-Host ""

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Start InventoryService
Write-Host "[3/3] Starting InventoryService on port 5219..." -ForegroundColor Yellow
$inventoryPath = Join-Path $ScriptDir "InventoryService"
Start-Process cmd -ArgumentList "/k", "cd /d `"$inventoryPath`" && dotnet run" -WindowStyle Normal
Write-Host "InventoryService starting in new window..." -ForegroundColor Green
Write-Host "Waiting 10 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Write-Host ""

# Start OrderService
Write-Host "[4/3] Starting OrderService on port 5194..." -ForegroundColor Yellow
$orderPath = Join-Path $ScriptDir "OrderService"
Start-Process cmd -ArgumentList "/k", "cd /d `"$orderPath`" && dotnet run" -WindowStyle Normal
Write-Host "OrderService starting in new window..." -ForegroundColor Green
Write-Host "Waiting 10 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All services should now be running!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check the service windows for startup logs." -ForegroundColor White
Write-Host ""
Write-Host "RabbitMQ Management: http://localhost:15672 (guest/guest)" -ForegroundColor White
Write-Host "InventoryService:    http://localhost:5219/api/inventory/health" -ForegroundColor White
Write-Host "OrderService:        http://localhost:5194/api/order/health" -ForegroundColor White
Write-Host ""

Write-Host "Running health checks..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Run health checks
Write-Host ""
Write-Host "Testing InventoryService..." -ForegroundColor Yellow
try {
    $invHealth = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/health" -ErrorAction Stop
    Write-Host "SUCCESS: InventoryService is healthy!" -ForegroundColor Green
    $invHealth | ConvertTo-Json
} catch {
    Write-Host "WARNING: InventoryService not responding yet (might still be starting)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Testing OrderService..." -ForegroundColor Yellow
try {
    $orderHealth = Invoke-RestMethod -Uri "http://localhost:5194/api/order/health" -ErrorAction Stop
    Write-Host "SUCCESS: OrderService is healthy!" -ForegroundColor Green
    $orderHealth | ConvertTo-Json
} catch {
    Write-Host "WARNING: OrderService not responding yet (might still be starting)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Startup complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Check service windows for 'RabbitMQ Consumer initialized' message" -ForegroundColor White
Write-Host "  2. Run tests:" -ForegroundColor White
Write-Host "     - Health: .\test-services.ps1" -ForegroundColor White
Write-Host "     - E2E:    .\test-create-order.ps1" -ForegroundColor White
Write-Host ""

