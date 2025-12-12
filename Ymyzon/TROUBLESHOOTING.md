# 🔧 TROUBLESHOOTING GUIDE - Ymyzon Services

## Common Issues & Solutions

---

## Issue 1: Services Not Starting in start-all.sh

### **Problem:**
Windows Explorer opens instead of launching services in CMD windows.

### **Root Cause:**
Git Bash's `cmd //c start` command has issues with path conversion.

### **Solutions:**

#### **Option A: Use PowerShell to Start (RECOMMENDED)**

Open PowerShell in Ymyzon folder and run:

```powershell
# Start InventoryService
Start-Process cmd -ArgumentList '/k','cd','/d','.\InventoryService','&&','dotnet','run'

# Wait 10 seconds
Start-Sleep -Seconds 10

# Start OrderService
Start-Process cmd -ArgumentList '/k','cd','/d','.\OrderService','&&','dotnet','run'
```

#### **Option B: Manual Start (3 Terminals)**

**Terminal 1: RabbitMQ**
```bash
docker start rabbitmq || docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

**Terminal 2: InventoryService**
```bash
cd InventoryService
dotnet run
# Wait for "RabbitMQ Consumer initialized and connected to localhost"
```

**Terminal 3: OrderService**
```bash
cd OrderService
dotnet run
# Wait for "Now listening on: http://localhost:5194"
```

#### **Option C: Use start-all.bat (Windows CMD)**

Open CMD (not Git Bash) in Ymyzon folder:
```cmd
start-all.bat
```

---

## Issue 2: Test Fails - "WARNING: Expected -5, but got different value"

### **Problem:**
`test-create-order.sh` step 5 reports unexpected inventory quantity change.

### **Root Causes:**

1. **Services not actually running**
2. **Old messages in RabbitMQ queue being processed**
3. **Multiple test runs consuming inventory**
4. **Message processing delay (too short wait time)**

### **Solutions:**

#### **Step 1: Verify Services Are Running**

```bash
# Check if services are listening on ports
netstat -ano | findstr "5219 5194"

# Expected output:
# TCP    0.0.0.0:5219    ...  LISTENING
# TCP    0.0.0.0:5194    ...  LISTENING
```

Or use PowerShell:
```powershell
# Check InventoryService
Invoke-WebRequest -Uri http://localhost:5219/api/inventory/health

# Check OrderService
Invoke-WebRequest -Uri http://localhost:5194/api/order/health
```

#### **Step 2: Check Current Inventory**

```bash
curl http://localhost:5219/api/inventory/Laptop
```

Expected format:
```json
{
  "productName": "Laptop",
  "availableQuantity": 100,  // or current quantity
  "lastUpdated": "2025-12-11T..."
}
```

#### **Step 3: Clear RabbitMQ Queue (If Needed)**

Old messages in queue might be consuming inventory unexpectedly.

**Option A: RabbitMQ Management UI**
1. Open http://localhost:15672 (login: guest/guest)
2. Go to "Queues" tab
3. Click "order-queue"
4. Click "Purge Messages" or "Delete Queue"

**Option B: Restart RabbitMQ**
```bash
docker restart rabbitmq
# Wait 15 seconds for it to restart
sleep 15
```

#### **Step 4: Restart Services**

Services cache the RabbitMQ connection. After clearing queue, restart them:

1. Close the CMD windows running the services (or Ctrl+C in terminals)
2. Restart both services
3. Wait for "RabbitMQ Consumer initialized" message

#### **Step 5: Run Test Again**

```bash
bash test-create-order.sh
```

---

## Issue 3: Inventory Already Depleted

### **Problem:**
Inventory quantity is low or 0, so test can't proceed.

### **Solution: Restart InventoryService**

The inventory is in-memory and resets when service restarts:

1. Stop InventoryService (close CMD window or Ctrl+C)
2. Start it again:
   ```bash
   cd InventoryService
   dotnet run
   ```
3. Inventory will reset to:
   - Laptop: 100
   - Mouse: 500
   - Keyboard: 300
   - Monitor: 150

---

## Issue 4: RabbitMQ Not Running

### **Symptoms:**
- Services fail to start with RabbitMQ connection error
- "Unable to connect to localhost:5672"

### **Solution:**

```bash
# Check if RabbitMQ is running
docker ps | grep rabbitmq

# If not running, start it
docker start rabbitmq

# If doesn't exist, create it
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management

# Wait 15-20 seconds for initialization
```

Verify at: http://localhost:15672

---

## Issue 5: Port Already in Use

### **Symptoms:**
- "Address already in use"
- Service fails to start

### **Solution:**

**Find process using port:**
```bash
netstat -ano | findstr "5219"
# Note the PID (last column)

# Kill the process (replace PID with actual number)
taskkill /PID 12345 /F
```

Or use PowerShell:
```powershell
# Find and kill process on port 5219
Get-Process -Id (Get-NetTCPConnection -LocalPort 5219).OwningProcess | Stop-Process -Force

# For port 5194
Get-Process -Id (Get-NetTCPConnection -LocalPort 5194).OwningProcess | Stop-Process -Force
```

---

## Verification Checklist

Before running tests, verify:

- [ ] Docker Desktop is running
- [ ] RabbitMQ container is running: `docker ps | grep rabbitmq`
- [ ] InventoryService console shows "RabbitMQ Consumer initialized"
- [ ] OrderService console shows "Now listening on: http://localhost:5194"
- [ ] Health check works: `curl http://localhost:5219/api/inventory/health`
- [ ] Health check works: `curl http://localhost:5194/api/order/health`
- [ ] Inventory query works: `curl http://localhost:5219/api/inventory/Laptop`

---

## Clean Start Procedure

When things go wrong, do a complete clean restart:

### **Step 1: Stop Everything**

```bash
# Stop services (close CMD windows or Ctrl+C in terminals)

# Stop and remove RabbitMQ
docker stop rabbitmq
docker rm rabbitmq
```

### **Step 2: Start Fresh**

```bash
# 1. Start RabbitMQ
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
sleep 15

# 2. Start InventoryService (in separate terminal/window)
cd InventoryService
dotnet run

# 3. Start OrderService (in separate terminal/window)
cd OrderService
dotnet run

# 4. Wait for both services to show "ready" messages
sleep 5
```

### **Step 3: Run Tests**

```bash
# Health checks first
bash test-services.sh

# Then end-to-end test
bash test-create-order.sh
```

---

## Understanding Test Behavior

### **Expected Flow:**

1. **Before check:** Inventory = X (e.g., 100)
2. **Create order:** POST 5 Laptops
3. **Message published:** OrderService → RabbitMQ
4. **Wait 3 seconds:** Message processing time
5. **After check:** Inventory = X - 5 (e.g., 95)

### **Why Test Might Fail:**

- **Services not running:** Health check should fail first
- **Old messages in queue:** Previous test messages being processed
- **Multiple orders processed:** If queue has multiple messages
- **Timing issue:** 3 seconds not enough (increase to 5)
- **Service crashed:** Check console for errors

---

## Log Files

When using `start-background.sh`, logs are written to:
- `inventory-service.log`
- `order-service.log`

View logs:
```bash
tail -f inventory-service.log
tail -f order-service.log
```

Look for:
- `[Consumer] Received:` - Message received
- `Deducted X from Laptop` - Inventory updated
- `Order X processed successfully` - Order completed
- `[Publisher] Sent:` - Message sent

---

## Quick Commands Reference

```bash
# Start everything (PowerShell)
Start-Process cmd -ArgumentList '/k','cd','/d','.\InventoryService','&&','dotnet','run'
Start-Sleep -Seconds 10
Start-Process cmd -ArgumentList '/k','cd','/d','.\OrderService','&&','dotnet','run'

# Health checks
curl http://localhost:5219/api/inventory/health
curl http://localhost:5194/api/order/health

# Check inventory
curl http://localhost:5219/api/inventory/all

# Create test order (PowerShell)
Invoke-RestMethod -Uri http://localhost:5194/api/order/create -Method Post -Body '{"id":99,"productName":"Laptop","quantity":5,"price":1299.99}' -ContentType "application/json"

# Check RabbitMQ
docker ps | grep rabbitmq
curl http://localhost:15672

# Kill processes on ports
taskkill /F /FI "IMAGENAME eq dotnet.exe"
```

---

## Still Having Issues?

1. **Check service console windows** for error messages
2. **Check RabbitMQ Management UI** (http://localhost:15672) for queue status
3. **Restart everything** from clean state
4. **Verify Docker Desktop is running**
5. **Check Windows Firewall** isn't blocking ports 5194, 5219, 5672, 15672

---

## Success Indicators

When everything works correctly, you'll see:

**InventoryService console:**
```
info: Now listening on: http://localhost:5219
info: RabbitMQ Consumer initialized and connected to localhost
info: [Consumer] Received: {"id":1,"productName":"Laptop"...}
info: Deducted 5 from Laptop. New quantity: 95
info: Order 1 processed successfully
```

**OrderService console:**
```
info: Now listening on: http://localhost:5194
[Publisher] Connected to RabbitMQ at localhost
info: Order 1 created and published to queue
[Publisher] Sent: {"id":1,"productName":"Laptop","quantity":5...}
```

**Test output:**
```
1. Testing OrderService Health...
SUCCESS: OrderService is running!

2. Checking initial Laptop inventory...
Before Order - Laptop quantity: 100

3. Creating order for 5 Laptops...
SUCCESS: Order created!

4. Waiting for RabbitMQ message processing...

5. Checking updated Laptop inventory...
After Order - Laptop quantity: 95

========================================
SUCCESS! Inventory was deducted by 5!
Before: 100 -> After: 95
========================================
```

This confirms the entire message flow is working! 🎉

