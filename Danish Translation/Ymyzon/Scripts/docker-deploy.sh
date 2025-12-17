#!/bin/bash

echo "========================================"
echo "Docker Deployment Test"
echo "========================================"
echo ""

# Record start time
start_time=$(date +%s)

# Get Ymyzon root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"

# Step 1: Clean up
echo "[1/5] Cleaning up existing containers..."
cd "$YMYZON_ROOT"

# Stop and remove docker-compose services
docker-compose down -v > /dev/null 2>&1

# Also check for standalone RabbitMQ container
if docker ps -a --format '{{.Names}}' | grep -q '^rabbitmq$'; then
    echo "Removing standalone RabbitMQ container..."
    docker stop rabbitmq > /dev/null 2>&1
    docker rm rabbitmq > /dev/null 2>&1
fi

echo "Cleanup complete"
echo ""

# Step 2: Build images
echo "[2/5] Building Docker images..."
build_start=$(date +%s)
docker-compose build --no-cache
build_end=$(date +%s)
build_time=$((build_end - build_start))
echo "Build completed in $build_time seconds"
echo ""

# Step 3: Start services
echo "[3/5] Starting services..."
deploy_start=$(date +%s)
docker-compose up -d
deploy_end=$(date +%s)
deploy_time=$((deploy_end - deploy_start))
echo "Services started in $deploy_time seconds"
echo ""

# Step 4: Wait for services
echo "[4/5] Waiting for services to be healthy..."
sleep 30

# Step 5: Health checks
echo "[5/5] Running health checks..."
echo ""

inv_health=$(curl -s http://localhost:5219/api/inventory/health)
if [ $? -eq 0 ]; then
    echo "✓ InventoryService: Healthy"
else
    echo "✗ InventoryService: Not responding"
fi

order_health=$(curl -s http://localhost:5194/api/order/health)
if [ $? -eq 0 ]; then
    echo "✓ OrderService: Healthy"
else
    echo "✗ OrderService: Not responding"
fi

echo ""

# Calculate total time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Display results
echo "========================================"
echo "Deployment Metrics"
echo "========================================"
echo "Build Time:      $build_time seconds"
echo "Deploy Time:     $deploy_time seconds"
echo "Total Time:      $total_time seconds"
echo "========================================"
echo ""

echo "Services are running!"
echo "RabbitMQ UI: http://localhost:15672 (guest/guest)"
echo "InventoryService: http://localhost:5219"
echo "OrderService: http://localhost:5194"
echo ""
echo "To test: bash test-docker.sh"
echo "To stop: docker-compose down"

