# 🚀 YMYZON - Complete Manual Startup Guide

## Current Status
- ✅ Both services build successfully
- ✅ RabbitMQ.Client v7 async implementation complete
- ✅ InventoryService tested and working
- ⚠️ Need to start all services together

## Step-by-Step Instructions

### Step 1: Start RabbitMQ (Terminal 1)

```bash
# Check if RabbitMQ container exists
docker ps -a | grep rabbitmq

# If it exists, start it:
docker start rabbitmq

# If it doesn't exist, create it:
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management

# Verify it's running:
docker ps | grep rabbitmq

# Wait 15 seconds for RabbitMQ to fully initialize
```

**Verification:**
- Open browser: http://localhost:15672
- Login: guest / guest
- You should see the RabbitMQ Management UI

---

### Step 2: Start InventoryService (Terminal 2 / CMD Window)

```bash
cd "C:\Users\elksk\Documents\rimeligt legit skolesager\Programmeringsprojekter\SIN\exam-sin-synopsis\Ymyzon\InventoryService"
dotnet run
```

**Expected Console Output:**
```
Building...
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5219
info: Microsoft.Hosting.Lifetime[0]
      Application started.
info: InventoryService.Messaging.RabbitMQConsumer[0]
      RabbitMQ Consumer initialized and connected to localhost
```

**DO NOT CLOSE THIS WINDOW!** Keep it running.

**Verification (in another terminal):**
```powershell
Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/health"
# Should return: {"status":"Healthy","service":"InventoryService"}
```

---

### Step 3: Start OrderService (Terminal 3 / CMD Window)

```bash
cd "C:\Users\elksk\Documents\rimeligt legit skolesager\Programmeringsprojekter\SIN\exam-sin-synopsis\Ymyzon\OrderService"
dotnet run
```

**Expected Console Output:**
```
Building...
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5194
info: Microsoft.Hosting.Lifetime[0]
      Application started.
```

**Note:** Publisher will connect to RabbitMQ lazily (on first order creation).

**DO NOT CLOSE THIS WINDOW!** Keep it running.

**Verification (in another terminal):**
```powershell
Invoke-RestMethod -Uri "http://localhost:5194/api/order/health"
# Should return: {"status":"Healthy","service":"OrderService"}
```

---

### Step 4: Run Automated Tests (Terminal 4)

```bash
cd "C:\Users\elksk\Documents\rimeligt legit skolesager\Programmeringsprojekter\SIN\exam-sin-synopsis\Ymyzon"

# Test 1: Health checks
powershell -ExecutionPolicy Bypass -File test-services.ps1

# Test 2: End-to-end order flow
powershell -ExecutionPolicy Bypass -File test-create-order.ps1
```

---

## Manual Testing (Alternative)

### Test 1: Check Initial Inventory

```powershell
$inventory = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/all"
$inventory | ConvertTo-Json -Depth 3
```

**Expected:** Laptop=100, Mouse=500, Keyboard=300, Monitor=150

---

### Test 2: Create an Order

```powershell
$order = @{
    id = 1
    productName = "Laptop"
    quantity = 5
    price = 1299.99
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5194/api/order/create" `
    -Method Post `
    -Body $order `
    -ContentType "application/json"

$response | ConvertTo-Json
```

**Watch the console windows:**
- **OrderService window:** Should show `[Publisher] Sent: {order data}`
- **InventoryService window:** Should show `[Consumer] Received:...` and `Deducted 5 from Laptop...`

---

### Test 3: Verify Inventory Updated

```powershell
$laptop = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/Laptop"
$laptop | ConvertTo-Json
```

**Expected:** `availableQuantity: 95` (was 100, now 95 after ordering 5)

---

## Success Criteria ✅

When everything works, you should see:

1. ✅ RabbitMQ running in Docker
2. ✅ InventoryService console showing "RabbitMQ Consumer initialized"
3. ✅ OrderService console showing "Now listening on: http://localhost:5194"
4. ✅ Order creation returns success message
5. ✅ InventoryService console shows message received and processed
6. ✅ Laptop inventory decreased from 100 to 95
7. ✅ RabbitMQ Management UI shows "order-queue" with message activity

---

## Troubleshooting

### Problem: OrderService won't start
**Solution:** Make sure RabbitMQ is running FIRST. The service itself doesn't connect until you create an order, but Docker must be available.

### Problem: "Unable to connect to remote server"
**Solution:** Wait longer. Services need 5-10 seconds to fully start.

### Problem: Messages not being consumed
**Solution:** Check InventoryService console for errors. Make sure both services are actually running.

### Problem: Docker daemon not running
**Solution:** Start Docker Desktop and wait for it to fully initialize.

---

## Quick Start (One-Liner - Windows CMD)

```cmd
start-all.bat
```

This will:
1. Start RabbitMQ
2. Open InventoryService in separate window
3. Open OrderService in separate window
4. Run health checks

---

## What's Next?

Once you've verified the end-to-end flow works:

1. ✅ **Document success** - Take screenshots of console logs
2. ✅ **Record metrics** - Note startup time, response times
3. ⏭️ **Phase 2: Dockerization** - Create Dockerfiles
4. ⏭️ **Phase 3: Manual Deployments** - Time 5 manual deployments
5. ⏭️ **Phase 4: CI/CD** - GitHub Actions automation
6. ⏭️ **Phase 5: Synopsis Writing** - Document your findings

---

**You're 80% there! The code is solid, just need to run it!** 🌞

