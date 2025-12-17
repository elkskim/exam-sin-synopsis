#!/bin/bash

echo "Running Manual Test with File Output..."

# Get Ymyzon root directory (parent of Scripts)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"

# Test 1: Health checks
echo "Testing health endpoints..."
curl -s http://localhost:5219/api/inventory/health > "$YMYZON_ROOT/inventory-health.json"
curl -s http://localhost:5194/api/order/health > "$YMYZON_ROOT/order-health.json"

echo "Health check results saved to:"
echo "  - inventory-health.json"
echo "  - order-health.json"

# Test 2: Get initial inventory
echo ""
echo "Getting initial inventory..."
curl -s http://localhost:5219/api/inventory/Laptop > "$YMYZON_ROOT/before-inventory.json"
echo "Initial inventory saved to: before-inventory.json"

# Test 3: Create order
echo ""
echo "Creating order for 5 Laptops..."
curl -s -X POST http://localhost:5194/api/order/create \
    -H "Content-Type: application/json" \
    -d '{"id":10,"productName":"Laptop","quantity":5,"price":1299.99}' \
    > "$YMYZON_ROOT/order-response.json"
echo "Order response saved to: order-response.json"

# Wait for processing
echo ""
echo "Waiting 3 seconds for message processing..."
sleep 3

# Test 4: Get updated inventory
echo "Getting updated inventory..."
curl -s http://localhost:5219/api/inventory/Laptop > "$YMYZON_ROOT/after-inventory.json"
echo "Updated inventory saved to: after-inventory.json"

echo ""
echo "========================================="
echo "TEST COMPLETE!"
echo "========================================="
echo ""
echo "Check these files for results:"
echo "  1. inventory-health.json"
echo "  2. order-health.json"
echo "  3. before-inventory.json (should show 100 or previous quantity)"
echo "  4. order-response.json"
echo "  5. after-inventory.json (should be 5 less than before)"
echo ""
echo "Opening files..."
cat "$YMYZON_ROOT/inventory-health.json"
echo ""
cat "$YMYZON_ROOT/order-health.json"
echo ""
echo "Before inventory:"
cat "$YMYZON_ROOT/before-inventory.json"
echo ""
echo ""
echo "After inventory:"
cat "$YMYZON_ROOT/after-inventory.json"
echo ""

