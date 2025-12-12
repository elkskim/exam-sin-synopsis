#!/bin/bash

echo "Testing Dockerized Ymyzon Services..."
echo ""

# Check containers
echo "1. Checking containers..."
docker-compose ps
echo ""

# Health checks
echo "2. Testing health endpoints..."
inv_health=$(curl -s http://localhost:5219/api/inventory/health)
if [ $? -eq 0 ]; then
    echo "✓ InventoryService:"
    echo "$inv_health" | jq . 2>/dev/null || echo "$inv_health"
else
    echo "✗ InventoryService failed"
    exit 1
fi

echo ""

order_health=$(curl -s http://localhost:5194/api/order/health)
if [ $? -eq 0 ]; then
    echo "✓ OrderService:"
    echo "$order_health" | jq . 2>/dev/null || echo "$order_health"
else
    echo "✗ OrderService failed"
    exit 1
fi

echo ""

# Get initial inventory
echo "3. Getting initial inventory..."
before_inv=$(curl -s http://localhost:5219/api/inventory/Laptop)
before_qty=$(echo "$before_inv" | jq -r '.availableQuantity' 2>/dev/null)
echo "Before Order - Laptop quantity: $before_qty"

echo ""

# Create order
echo "4. Creating order for 5 Laptops..."
order_response=$(curl -s -X POST http://localhost:5194/api/order/create \
    -H "Content-Type: application/json" \
    -d '{"id":100,"productName":"Laptop","quantity":5,"price":1299.99}')

echo "✓ Order created:"
echo "$order_response" | jq . 2>/dev/null || echo "$order_response"

echo ""

# Wait for processing
echo "5. Waiting for message processing (5 seconds)..."
sleep 5

# Check updated inventory
echo "6. Checking updated inventory..."
after_inv=$(curl -s http://localhost:5219/api/inventory/Laptop)
after_qty=$(echo "$after_inv" | jq -r '.availableQuantity' 2>/dev/null)
echo "After Order - Laptop quantity: $after_qty"

echo ""

# Verify change
difference=$((before_qty - after_qty))
if [ $difference -eq 5 ]; then
    echo "========================================"
    echo "SUCCESS! Inventory was deducted by 5!"
    echo "Before: $before_qty -> After: $after_qty"
    echo "========================================"
else
    echo "========================================"
    echo "WARNING: Expected -5, got -$difference"
    echo "Before: $before_qty -> After: $after_qty"
    echo "========================================"
fi

echo ""
echo "Docker deployment test complete!"
echo ""
echo "View logs:"
echo "  docker-compose logs inventory-service"
echo "  docker-compose logs order-service"
echo "  docker-compose logs rabbitmq"
# Test Dockerized Ymyzon Services

Write-Host "Testing Dockerized Ymyzon Services..." -ForegroundColor Cyan
Write-Host ""

# Check services are running
Write-Host "1. Checking containers..." -ForegroundColor Yellow
docker-compose ps
Write-Host ""

# Health checks
Write-Host "2. Testing health endpoints..." -ForegroundColor Yellow
try {
    $invHealth = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/health"
    Write-Host "✓ InventoryService:" -ForegroundColor Green
    $invHealth | ConvertTo-Json
} catch {
    Write-Host "✗ InventoryService failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

try {
    $orderHealth = Invoke-RestMethod -Uri "http://localhost:5194/api/order/health"
    Write-Host "✓ OrderService:" -ForegroundColor Green
    $orderHealth | ConvertTo-Json
} catch {
    Write-Host "✗ OrderService failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Get initial inventory
Write-Host "3. Getting initial inventory..." -ForegroundColor Yellow
$beforeInv = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/Laptop"
$beforeQty = $beforeInv.availableQuantity
Write-Host "Before Order - Laptop quantity: $beforeQty" -ForegroundColor Cyan

Write-Host ""

# Create order
Write-Host "4. Creating order for 5 Laptops..." -ForegroundColor Yellow
$order = @{
    id = 100
    productName = "Laptop"
    quantity = 5
    price = 1299.99
} | ConvertTo-Json

$orderResponse = Invoke-RestMethod -Uri "http://localhost:5194/api/order/create" `
    -Method Post `
    -Body $order `
    -ContentType "application/json"

Write-Host "✓ Order created:" -ForegroundColor Green
$orderResponse | ConvertTo-Json

Write-Host ""

# Wait for message processing
Write-Host "5. Waiting for message processing (5 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Check updated inventory
Write-Host "6. Checking updated inventory..." -ForegroundColor Yellow
$afterInv = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/Laptop"
$afterQty = $afterInv.availableQuantity
Write-Host "After Order - Laptop quantity: $afterQty" -ForegroundColor Cyan

Write-Host ""

# Verify change
$difference = $beforeQty - $afterQty
if ($difference -eq 5) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! Inventory was deducted by 5!" -ForegroundColor Green
    Write-Host "Before: $beforeQty -> After: $afterQty" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "WARNING: Expected -5, got -$difference" -ForegroundColor Yellow
    Write-Host "Before: $beforeQty -> After: $afterQty" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Docker deployment test complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "View logs:" -ForegroundColor White
Write-Host "  docker-compose logs inventory-service" -ForegroundColor Gray
Write-Host "  docker-compose logs order-service" -ForegroundColor Gray
Write-Host "  docker-compose logs rabbitmq" -ForegroundColor Gray

