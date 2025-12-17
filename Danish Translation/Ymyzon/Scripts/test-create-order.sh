#!/bin/bash

echo "Testing Order Creation and Inventory Update..."
echo ""

# Check OrderService is running
echo "1. Testing OrderService Health on port 5194..."
order_health=$(curl -s http://localhost:5194/api/order/health)
if [ $? -ne 0 ]; then
    echo "ERROR: OrderService not responding"
    exit 1
fi
echo "SUCCESS: OrderService is running!"
echo "$order_health" | jq . 2>/dev/null || echo "$order_health"

echo ""

# Get initial inventory for Laptop
echo "2. Checking initial Laptop inventory..."
before_inventory=$(curl -s http://localhost:5219/api/inventory/Laptop)
if [ $? -eq 0 ]; then
    before_qty=$(echo "$before_inventory" | jq -r '.availableQuantity' 2>/dev/null)
    echo "Before Order - Laptop quantity: $before_qty"
else
    echo "ERROR: Could not get inventory"
    exit 1
fi

echo ""

# Create an order
echo "3. Creating order for 5 Laptops..."
order_response=$(curl -s -X POST http://localhost:5194/api/order/create \
    -H "Content-Type: application/json" \
    -d '{
        "id": 1,
        "productName": "Laptop",
        "quantity": 5,
        "price": 1299.99
    }')

if [ $? -eq 0 ]; then
    echo "SUCCESS: Order created!"
    echo "$order_response" | jq . 2>/dev/null || echo "$order_response"
else
    echo "ERROR: Could not create order"
    exit 1
fi

echo ""

# Wait a moment for message processing
echo "4. Waiting for RabbitMQ message processing..."
sleep 3

# Check updated inventory
echo "5. Checking updated Laptop inventory..."
after_inventory=$(curl -s http://localhost:5219/api/inventory/Laptop)
if [ $? -eq 0 ]; then
    after_qty=$(echo "$after_inventory" | jq -r '.availableQuantity' 2>/dev/null)
    echo "After Order - Laptop quantity: $after_qty"
    
    # Check if we got valid numbers
    if [[ "$before_qty" =~ ^[0-9]+$ ]] && [[ "$after_qty" =~ ^[0-9]+$ ]]; then
        difference=$((before_qty - after_qty))
        if [ $difference -eq 5 ]; then
            echo ""
            echo "========================================"
            echo "SUCCESS! Inventory was deducted by 5!"
            echo "Before: $before_qty -> After: $after_qty"
            echo "========================================"
        else
            echo ""
            echo "========================================"
            echo "WARNING: Inventory change unexpected"
            echo "Before: $before_qty"
            echo "After:  $after_qty"
            echo "Change: $difference (expected -5)"
            echo "========================================"
            echo ""
            echo "Possible reasons:"
            echo "1. Message still processing (wait longer)"
            echo "2. Service consumed older messages from queue"
            echo "3. Multiple tests running simultaneously"
            echo ""
            echo "Check InventoryService console for message processing logs"
        fi
    else
        echo "ERROR: Invalid quantity values (before: '$before_qty', after: '$after_qty')"
        exit 1
    fi
else
    echo "ERROR: Could not get inventory"
    exit 1
fi

echo ""
echo "Test complete! Check the service console windows for logs."

