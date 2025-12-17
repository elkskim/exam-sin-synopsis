#!/bin/bash

echo "========================================"
echo "Starting Ymyzon Services (Background)"
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
echo "RabbitMQ ready!"
echo ""

# Get the absolute path to the script directory and parent (Ymyzon root)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"

echo "[2/3] Starting InventoryService on port 5219..."
cd "$YMYZON_ROOT/InventoryService"
dotnet run > "$YMYZON_ROOT/inventory-service.log" 2>&1 &
INVENTORY_PID=$!
echo "InventoryService started (PID: $INVENTORY_PID)"
echo "Logs: inventory-service.log"
sleep 8
echo ""

echo "[3/3] Starting OrderService on port 5194..."
cd "$YMYZON_ROOT/OrderService"
dotnet run > "$YMYZON_ROOT/order-service.log" 2>&1 &
ORDER_PID=$!
echo "OrderService started (PID: $ORDER_PID)"
echo "Logs: order-service.log"
sleep 8
echo ""

echo "========================================"
echo "All services running!"
echo "========================================"
echo ""
echo "Services:"
echo "  RabbitMQ:         http://localhost:15672 (guest/guest)"
echo "  InventoryService: http://localhost:5219 (PID: $INVENTORY_PID)"
echo "  OrderService:     http://localhost:5194 (PID: $ORDER_PID)"
echo ""
echo "Logs:"
echo "  InventoryService: tail -f $YMYZON_ROOT/inventory-service.log"
echo "  OrderService:     tail -f $YMYZON_ROOT/order-service.log"
echo ""
echo "To stop services:"
echo "  kill $INVENTORY_PID $ORDER_PID"
echo ""

# Save PIDs for easy cleanup in Ymyzon root
echo "$INVENTORY_PID" > "$YMYZON_ROOT/.inventory.pid"
echo "$ORDER_PID" > "$YMYZON_ROOT/.order.pid"

echo "Running health checks in 5 seconds..."
sleep 5

cd "$SCRIPT_DIR"
bash test-services.sh

