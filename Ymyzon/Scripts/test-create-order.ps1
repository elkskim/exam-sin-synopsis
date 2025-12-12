Write-Host "Testing Order Creation and Inventory Update..." -ForegroundColor Cyan
Write-Host ""

# Check OrderService is running
Write-Host "1. Testing OrderService Health on port 5194..." -ForegroundColor Yellow
try {
    $orderHealth = Invoke-RestMethod -Uri "http://localhost:5194/api/order/health" -Method Get
    Write-Host "SUCCESS: OrderService is running!" -ForegroundColor Green
    $orderHealth | ConvertTo-Json
} catch {
    Write-Host "ERROR: OrderService not responding:" $_.Exception.Message -ForegroundColor Red
    exit
}

Write-Host ""

# Get initial inventory for Laptop
Write-Host "2. Checking initial Laptop inventory..." -ForegroundColor Yellow
try {
    $beforeInventory = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/Laptop" -Method Get
    Write-Host "Before Order - Laptop quantity:" $beforeInventory.availableQuantity -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: Could not get inventory:" $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

# Create an order
Write-Host "3. Creating order for 5 Laptops..." -ForegroundColor Yellow
$orderBody = @{
    id = 1
    productName = "Laptop"
    quantity = 5
    price = 1299.99
} | ConvertTo-Json

try {
    $orderResponse = Invoke-RestMethod -Uri "http://localhost:5194/api/order/create" -Method Post -Body $orderBody -ContentType "application/json"
    Write-Host "SUCCESS: Order created!" -ForegroundColor Green
    $orderResponse | ConvertTo-Json
} catch {
    Write-Host "ERROR: Could not create order:" $_.Exception.Message -ForegroundColor Red
    exit
}

Write-Host ""

# Wait a moment for message processing
Write-Host "4. Waiting for RabbitMQ message processing..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

# Check updated inventory
Write-Host "5. Checking updated Laptop inventory..." -ForegroundColor Yellow
try {
    $afterInventory = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/Laptop" -Method Get
    Write-Host "After Order - Laptop quantity:" $afterInventory.availableQuantity -ForegroundColor Cyan
    
    $difference = $beforeInventory.availableQuantity - $afterInventory.availableQuantity
    if ($difference -eq 5) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "SUCCESS! Inventory was deducted by 5!" -ForegroundColor Green
        Write-Host "Before: $($beforeInventory.availableQuantity) -> After: $($afterInventory.availableQuantity)" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Expected -5, but got -$difference" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR: Could not get inventory:" $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Test complete! Check the service console windows for logs." -ForegroundColor Cyan

