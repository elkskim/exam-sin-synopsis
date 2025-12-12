Write-Host "Testing Ymyzon Services..." -ForegroundColor Cyan
Write-Host ""

# Wait a moment for services to start
Start-Sleep -Seconds 3

# Test InventoryService
Write-Host "Testing InventoryService Health..." -ForegroundColor Yellow
try {
    $inventoryHealth = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/health" -Method Get
    Write-Host "SUCCESS: InventoryService is running!" -ForegroundColor Green
    $inventoryHealth | ConvertTo-Json
} catch {
    Write-Host "ERROR: InventoryService not responding:" $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

# Test OrderService
Write-Host "Testing OrderService Health..." -ForegroundColor Yellow
try {
    $orderHealth = Invoke-RestMethod -Uri "http://localhost:5194/api/order/health" -Method Get
    Write-Host "SUCCESS: OrderService is running!" -ForegroundColor Green
    $orderHealth | ConvertTo-Json
} catch {
    Write-Host "ERROR: OrderService not responding:" $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

# Check all inventory
Write-Host "Getting Initial Inventory..." -ForegroundColor Yellow
try {
    $inventory = Invoke-RestMethod -Uri "http://localhost:5219/api/inventory/all" -Method Get
    Write-Host "SUCCESS: Current Inventory:" -ForegroundColor Green
    $inventory | ConvertTo-Json -Depth 5
} catch {
    Write-Host "ERROR: Could not get inventory:" $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Ready to test order creation!" -ForegroundColor Cyan
Write-Host "Run: test-create-order.ps1" -ForegroundColor Cyan

