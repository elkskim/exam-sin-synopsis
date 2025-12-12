#!/bin/bash

echo "Stopping Ymyzon services..."

# Get Ymyzon root directory (parent of Scripts)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"

# Read PIDs from files
if [ -f "$YMYZON_ROOT/.inventory.pid" ]; then
    INVENTORY_PID=$(cat "$YMYZON_ROOT/.inventory.pid")
    if kill -0 "$INVENTORY_PID" 2>/dev/null; then
        kill "$INVENTORY_PID"
        echo "✓ Stopped InventoryService (PID: $INVENTORY_PID)"
    else
        echo "✗ InventoryService not running"
    fi
    rm "$YMYZON_ROOT/.inventory.pid"
fi

if [ -f "$YMYZON_ROOT/.order.pid" ]; then
    ORDER_PID=$(cat "$YMYZON_ROOT/.order.pid")
    if kill -0 "$ORDER_PID" 2>/dev/null; then
        kill "$ORDER_PID"
        echo "✓ Stopped OrderService (PID: $ORDER_PID)"
    else
        echo "✗ OrderService not running"
    fi
    rm "$YMYZON_ROOT/.order.pid"
fi

# Optionally stop RabbitMQ
read -p "Stop RabbitMQ container? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker stop rabbitmq > /dev/null 2>&1
    echo "✓ Stopped RabbitMQ"
fi

echo ""
echo "Services stopped!"

