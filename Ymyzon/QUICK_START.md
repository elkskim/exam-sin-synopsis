# 🚀 QUICK START - Ymyzon Microservices

Complete guide to starting, testing, and troubleshooting the Ymyzon system.

---

## Prerequisites

- [ ] Docker Desktop running
- [ ] .NET 9 SDK installed
- [ ] Terminal (PowerShell, Git Bash, or CMD)

---

## Starting Services

### **Option 1: PowerShell (Recommended for Windows)** ⭐

```powershell
cd Ymyzon\Scripts
.\start-all.ps1
```

**What it does:**
1. ✅ Checks Docker is running
2. ✅ Starts/creates RabbitMQ container
3. ✅ Launches InventoryService (new CMD window)
4. ✅ Launches OrderService (new CMD window)
5. ✅ Waits for initialization
6. ✅ Runs health checks automatically

### **Option 2: Bash Script**

```bash
cd Ymyzon/Scripts
bash start-all.sh
```

Same functionality as PowerShell version but for Git Bash/Linux.

### **Option 3: Background Services**

```bash
cd Ymyzon/Scripts
bash start-background.sh   # Starts services in background
# Services log to: inventory-service.log, order-service.log

# To stop:
bash stop-services.sh
```

### **Option 4: Manual (3 Terminals)**

**Terminal 1: RabbitMQ**
```bash
docker start rabbitmq || docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
# Wait 15 seconds for initialization
```

**Terminal 2: InventoryService**
```bash
cd InventoryService
dotnet run
# Wait for: "RabbitMQ Consumer initialized and connected to localhost"
```

**Terminal 3: OrderService**
```bash
cd OrderService
dotnet run
# Wait for: "Now listening on: http://localhost:5194"
```

---

## Testing the System

### **Health Checks**

**PowerShell:**
```powershell
cd Scripts
.\test-services.ps1
```

**Bash:**
```bash
cd Scripts
bash test-services.sh
```

**Expected Output:**
```
Testing InventoryService Health...
SUCCESS: InventoryService is running!
{"status":"Healthy","service":"InventoryService"}

Testing OrderService Health...
SUCCESS: OrderService is running!
{"status":"Healthy","service":"OrderService"}

Getting Initial Inventory...
SUCCESS: Current Inventory:
{
  "Laptop": {"productName":"Laptop","availableQuantity":100},
  "Mouse": {"productName":"Mouse","availableQuantity":500},
  ...
}
```

---

### **End-to-End Order Test**

**PowerShell:**
```powershell
cd Scripts
.\test-create-order.ps1
```

**Bash:**
```bash
cd Scripts
bash test-create-order.sh
```

**What it does:**
1. Checks OrderService is running
2. Gets initial Laptop inventory (e.g., 100)
3. Creates order for 5 Laptops
4. Waits 3 seconds for message processing
5. Checks updated inventory (should be 95)

**Expected Output:**
```
1. Testing OrderService Health on port 5194...
SUCCESS: OrderService is running!

2. Checking initial Laptop inventory...
Before Order - Laptop quantity: 100

3. Creating order for 5 Laptops...
SUCCESS: Order created!
{"message":"Order created successfully!","orderId":1,...}

4. Waiting for RabbitMQ message processing...

5. Checking updated Laptop inventory...
After Order - Laptop quantity: 95

========================================
SUCCESS! Inventory was deducted by 5!
Before: 100 -> After: 95
========================================
```

---

### **Manual Test with File Output**

```bash
bash test-manual.sh
```

Creates JSON files with test results:
- `inventory-health.json`
- `order-health.json`
- `before-inventory.json`
- `after-inventory.json`
- `order-response.json`

---

## Verification Checklist

Before running tests, verify:

- [ ] Docker Desktop is running
- [ ] RabbitMQ container is running: `docker ps | grep rabbitmq`
- [ ] InventoryService window shows "RabbitMQ Consumer initialized"
- [ ] OrderService window shows "Now listening on: http://localhost:5194"
- [ ] Health endpoints respond:
  ```bash
  curl http://localhost:5219/api/inventory/health
  curl http://localhost:5194/api/order/health
  ```

---

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **RabbitMQ UI** | http://localhost:15672 | Management interface (guest/guest) |
| **InventoryService** | http://localhost:5219 | Inventory management API |
| **OrderService** | http://localhost:5194 | Order creation API |

---

## Common Issues & Quick Fixes

### **Services Won't Start**

```bash
# Check Docker is running
docker ps

# Restart RabbitMQ
docker restart rabbitmq

# Check ports are free
netstat -ano | findstr "5219 5194"
```

### **Test Fails at Step 5 (Inventory Mismatch)**

**Cause:** Old messages in RabbitMQ queue or services not running.

**Solution:**
1. Clear RabbitMQ queue:
   - Open http://localhost:15672
   - Go to Queues → order-queue → Purge Messages
2. Restart both services (inventory resets to 100)
3. Run test again

### **Port Already in Use**

```powershell
# Find and kill process using port (PowerShell)
Get-Process -Id (Get-NetTCPConnection -LocalPort 5219).OwningProcess | Stop-Process -Force
```

### **RabbitMQ Not Running**

```bash
docker ps -a | grep rabbitmq   # Check if exists
docker start rabbitmq          # Start if stopped
# Or create new:
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

---

## Understanding the Message Flow

```
1. Client → OrderService (REST API)
   POST /api/order/create
   {"id":1,"productName":"Laptop","quantity":5,"price":1299.99}

2. OrderService → RabbitMQ
   Publishes JSON message to "order-queue"

3. RabbitMQ → InventoryService
   Background consumer receives message

4. InventoryService processes order
   Deducts 5 from Laptop inventory (100 → 95)

5. InventoryService ACKs message
   Message removed from queue
```

---

## Console Output Examples

**InventoryService Window:**
```
info: Now listening on: http://localhost:5219
info: RabbitMQ Consumer initialized and connected to localhost
info: [Consumer] Received: {"id":1,"productName":"Laptop","quantity":5...}
info: Deducted 5 from Laptop. New quantity: 95
info: Order 1 processed successfully
```

**OrderService Window:**
```
info: Now listening on: http://localhost:5194
[Publisher] Connected to RabbitMQ at localhost
info: Order 1 created and published to queue
[Publisher] Sent: {"id":1,"productName":"Laptop","quantity":5...}
```

---

## Available Scripts

| Script | Purpose | Platform |
|--------|---------|----------|
| `start-all.ps1` | Start all services | PowerShell ⭐ |
| `start-all.sh` | Start all services | Bash |
| `start-all.bat` | Start all services | CMD |
| `start-background.sh` | Background services | Bash |
| `stop-services.sh` | Stop background services | Bash |
| `test-services.ps1` | Health checks | PowerShell |
| `test-services.sh` | Health checks | Bash |
| `test-create-order.ps1` | End-to-end test | PowerShell |
| `test-create-order.sh` | End-to-end test | Bash |
| `test-manual.sh` | File-based test | Bash |

---

## Clean Restart Procedure

When things go wrong, start fresh:

```bash
# 1. Stop all services (close CMD windows or Ctrl+C)

# 2. Stop and remove RabbitMQ
docker stop rabbitmq
docker rm rabbitmq

# 3. Start fresh
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
# Wait 15 seconds

# 4. Start services
cd Scripts
.\start-all.ps1   # or bash start-all.sh

# 5. Run tests
.\test-services.ps1
.\test-create-order.ps1
```

---

## Success Indicators

When everything works:

- ✅ Two CMD windows running services with no errors
- ✅ Health endpoints return `{"status":"Healthy"}`
- ✅ Inventory shows initial quantities (Laptop: 100, etc.)
- ✅ Order creation succeeds
- ✅ Inventory decreases by order quantity
- ✅ Console logs show message flow

---

## Next Steps

Once services are running and tested:

1. ✅ **Phase 1 Complete** - Services functional
2. ⏭️ **Phase 2** - Create Dockerfiles
3. ⏭️ **Phase 3** - Manual deployment testing
4. ⏭️ **Phase 4** - CI/CD pipeline
5. ⏭️ **Phase 5** - Write synopsis

---

**Need more help?** See `TROUBLESHOOTING.md` for detailed solutions.

---

## 📁 Important Files

- `MANUAL_STARTUP_GUIDE.md` - Detailed instructions
- `PROJECT_SUMMARY.md` - Complete project status
- `TEST_RESULTS.md` - Testing results
- `test-services.ps1` - Health check script
- `test-create-order.ps1` - End-to-end test script
- `start-all.bat` - Automated startup

---

**Ready? LET'S GO!** 🚀

