#!/bin/bash

echo "========================================"
echo "Starting Ymyzon Microservices System"
echo "========================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "[1/3] Starting RabbitMQ..."
# Try to start existing container, or create new one
if docker ps -a --format '{{.Names}}' | grep -q '^rabbitmq$'; then
    docker start rabbitmq > /dev/null 2>&1
    echo "RabbitMQ container started"
else
    echo "RabbitMQ container not found, creating new one..."
    docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management > /dev/null 2>&1
    echo "RabbitMQ container created"
fi

echo "Waiting for RabbitMQ to initialize (15 seconds)..."
sleep 15
echo "RabbitMQ started!"
echo ""

# Get the absolute path to the script directory and parent (Ymyzon root)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"

echo "[2/3] Starting InventoryService on port 5219..."
# Start in new terminal window (Windows Git Bash)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows - convert to Windows path and use proper cmd syntax
    INVENTORY_PATH=$(cygpath -w "$YMYZON_ROOT/InventoryService")
    cmd.exe /c "start \"InventoryService\" cmd.exe /k \"cd /d $INVENTORY_PATH && dotnet run\""
else
    # Linux/Mac
    (cd "$YMYZON_ROOT/InventoryService" && dotnet run) &
fi
echo "InventoryService starting..."
sleep 8
echo ""

echo "[3/3] Starting OrderService on port 5194..."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows - convert to Windows path and use proper cmd syntax
    ORDER_PATH=$(cygpath -w "$YMYZON_ROOT/OrderService")
    cmd.exe /c "start \"OrderService\" cmd.exe /k \"cd /d $ORDER_PATH && dotnet run\""
else
    # Linux/Mac
    (cd "$YMYZON_ROOT/OrderService" && dotnet run) &
fi
echo "OrderService starting..."
sleep 8
echo ""

echo "========================================"
echo "All services should now be running!"
echo "========================================"
echo ""
echo "Check the service windows for startup logs."
echo ""
echo "RabbitMQ Management: http://localhost:15672 (guest/guest)"
echo "InventoryService:    http://localhost:5219/api/inventory/health"
echo "OrderService:        http://localhost:5194/api/order/health"
echo ""
echo "Waiting 5 more seconds for services to fully initialize..."
sleep 5
echo ""
echo "Running health checks..."
bash "$SCRIPT_DIR/test-services.sh"
#!/bin/bash

echo "Testing Ymyzon Services..."
echo ""

# Wait a moment for services to start
sleep 3

# Test InventoryService
echo "Testing InventoryService Health..."
inventory_health=$(curl -s http://localhost:5219/api/inventory/health)
if [ $? -eq 0 ]; then
    echo "SUCCESS: InventoryService is running!"
    echo "$inventory_health" | jq . 2>/dev/null || echo "$inventory_health"
else
    echo "ERROR: InventoryService not responding"
fi

echo ""

# Test OrderService
echo "Testing OrderService Health..."
order_health=$(curl -s http://localhost:5194/api/order/health)
if [ $? -eq 0 ]; then
    echo "SUCCESS: OrderService is running!"
    echo "$order_health" | jq . 2>/dev/null || echo "$order_health"
else
    echo "ERROR: OrderService not responding"
fi

echo ""

# Check all inventory
echo "Getting Initial Inventory..."
inventory=$(curl -s http://localhost:5219/api/inventory/all)
if [ $? -eq 0 ]; then
    echo "SUCCESS: Current Inventory:"
    echo "$inventory" | jq . 2>/dev/null || echo "$inventory"
else
    echo "ERROR: Could not get inventory"
fi

echo ""
echo "Ready to test order creation!"
echo "Run: ./test-create-order.sh"

