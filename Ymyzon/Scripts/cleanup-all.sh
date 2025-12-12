#!/bin/bash

# Complete cleanup script for Ymyzon deployment environment
# Removes all containers, networks, and volumes related to Ymyzon

echo "========================================="
echo "Ymyzon Complete Cleanup"
echo "========================================="
echo ""

# Get Ymyzon root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$YMYZON_ROOT"

echo "Cleaning up..."
echo ""

# 1. Stop and remove docker-compose services
echo "[1/4] Stopping docker-compose services..."
docker-compose down -v 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Docker-compose services removed"
else
    echo "ℹ No docker-compose services to remove"
fi
echo ""

# 2. Remove standalone RabbitMQ container
echo "[2/4] Checking for standalone RabbitMQ..."
if docker ps -a --format '{{.Names}}' | grep -q '^rabbitmq$'; then
    docker stop rabbitmq 2>/dev/null
    docker rm rabbitmq 2>/dev/null
    echo "✓ Standalone RabbitMQ container removed"
else
    echo "ℹ No standalone RabbitMQ container found"
fi
echo ""

# 3. Remove any Ymyzon-related containers
echo "[3/4] Checking for Ymyzon containers..."
ymyzon_containers=$(docker ps -a --format '{{.Names}}' | grep -i ymyzon)
if [ -n "$ymyzon_containers" ]; then
    echo "$ymyzon_containers" | xargs docker stop 2>/dev/null
    echo "$ymyzon_containers" | xargs docker rm 2>/dev/null
    echo "✓ Ymyzon containers removed"
else
    echo "ℹ No Ymyzon containers found"
fi
echo ""

# 4. Remove networks
echo "[4/4] Checking for Ymyzon networks..."
ymyzon_networks=$(docker network ls --format '{{.Name}}' | grep -i ymyzon)
if [ -n "$ymyzon_networks" ]; then
    echo "$ymyzon_networks" | xargs docker network rm 2>/dev/null
    echo "✓ Ymyzon networks removed"
else
    echo "ℹ No Ymyzon networks found"
fi
echo ""

# 5. Remove PID files
echo "Removing PID files..."
rm -f "$YMYZON_ROOT/.inventory.pid" 2>/dev/null
rm -f "$YMYZON_ROOT/.order.pid" 2>/dev/null
echo "✓ PID files removed"
echo ""

echo "========================================="
echo "✓ Cleanup Complete!"
echo "========================================="
echo ""
echo "All Ymyzon containers, networks, and volumes removed."
echo "You can now run a fresh deployment."
echo ""

