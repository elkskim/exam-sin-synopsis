# Manual vs Automated Deployment Comparison

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Manual Deployment Measurement" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will guide you through manual deployment" -ForegroundColor White
Write-Host "and measure the time for each step." -ForegroundColor White
Write-Host ""

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "..\manual-deployment-log-$timestamp.txt"

Write-Host "Results will be saved to: $logFile" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to begin"
Write-Host ""

# Record overall start time
$overallStart = Get-Date

# Initialize counters
$totalSteps = 0
$errors = 0
$stepTimes = @()

# Log function
function Log-Event {
    param($message)
    $message | Out-File -FilePath $logFile -Append
    Write-Host $message
}

# Step timing function
function Start-Step {
    param($stepName, $action)
    $script:stepStart = Get-Date
    $script:totalSteps++
    Log-Event "[$script:totalSteps] $stepName"
    Write-Host "Action: $action" -ForegroundColor Yellow
    Write-Host ""
}

function End-Step {
    $stepEnd = Get-Date
    $stepTime = ($stepEnd - $script:stepStart).TotalSeconds
    $script:stepTimes += $stepTime
    Log-Event "    Duration: $([math]::Round($stepTime, 2)) seconds"
    Log-Event ""
}

# Error recording function
function Record-Error {
    param($errorDesc)
    $script:errors++
    Log-Event "    ⚠️  ERROR: $errorDesc"
    $resolved = Read-Host "    Did you resolve it? (y/n)"
    if ($resolved -eq "y") {
        Log-Event "    ✓ Error resolved"
    } else {
        Log-Event "    ✗ Error not resolved"
    }
    Log-Event ""
}

Log-Event "========================================="
Log-Event "Manual Deployment Test - $timestamp"
Log-Event "========================================="
Log-Event ""

# STEP 1: Stop existing services
Start-Step "Stop existing services" "Manually stop any running services (Ctrl+C in terminals, docker stop, etc.)"
Read-Host "Press Enter when services are stopped"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 2: Clean Docker containers
Start-Step "Clean Docker containers" "Run: docker-compose down -v"
Read-Host "Press Enter when complete"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 2.5: Remove existing RabbitMQ container
Start-Step "Remove existing RabbitMQ container (if any)" "Run: docker stop rabbitmq; docker rm rabbitmq (ignore errors if container doesn't exist)"
Read-Host "Press Enter when complete"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 3: Start RabbitMQ
Start-Step "Start RabbitMQ" "Run: docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management"
Read-Host "Press Enter when RabbitMQ is started"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 4: Wait for RabbitMQ
Start-Step "Wait for RabbitMQ initialization" "Wait ~15 seconds for RabbitMQ to be ready"
Read-Host "Press Enter when RabbitMQ is ready"
End-Step

# STEP 5: Navigate to InventoryService
Start-Step "Navigate to InventoryService directory" "Run: cd InventoryService"
Read-Host "Press Enter when complete"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 6: Start InventoryService
Start-Step "Start InventoryService" "Open new terminal and run: dotnet run"
Read-Host "Press Enter when service is running"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 7: Navigate to OrderService
Start-Step "Navigate to OrderService directory" "Run: cd ..\OrderService"
Read-Host "Press Enter when complete"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 8: Start OrderService
Start-Step "Start OrderService" "Open new terminal and run: dotnet run"
Read-Host "Press Enter when service is running"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 9: Wait for services
Start-Step "Wait for services to initialize" "Wait for both services to show 'Now listening on' messages"
Read-Host "Press Enter when both services are ready"
End-Step

# STEP 10: Test InventoryService
Start-Step "Test InventoryService health" "Run: curl http://localhost:5219/api/inventory/health"
Read-Host "Press Enter when complete"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 11: Test OrderService
Start-Step "Test OrderService health" "Run: curl http://localhost:5194/api/order/health"
Read-Host "Press Enter when complete"
$hadError = Read-Host "Did you encounter any errors? (y/n)"
if ($hadError -eq "y") {
    $errorDesc = Read-Host "Describe error"
    Record-Error $errorDesc
}
End-Step

# STEP 12: Test order creation
Start-Step "Test order creation" "Run test script to create an order and verify inventory update"
Read-Host "Press Enter when test is complete"
$testPassed = Read-Host "Did the test pass? (y/n)"
if ($testPassed -ne "y") {
    $errorDesc = Read-Host "Describe issue"
    Record-Error $errorDesc
}
End-Step

# Calculate totals
$overallEnd = Get-Date
$totalTime = ($overallEnd - $overallStart).TotalSeconds
$avgStepTime = ($stepTimes | Measure-Object -Average).Average

# Summary
Log-Event "========================================="
Log-Event "Manual Deployment Summary"
Log-Event "========================================="
Log-Event "Total Steps:     $totalSteps"
Log-Event "Total Errors:    $errors"
Log-Event "Total Time:      $([math]::Round($totalTime, 2)) seconds ($([math]::Round($totalTime / 60, 2)) minutes)"
Log-Event "Avg Step Time:   $([math]::Round($avgStepTime, 2)) seconds"
Log-Event "Error Rate:      $([math]::Round(($errors / $totalSteps) * 100, 2))%"
Log-Event "========================================="

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Manual Deployment Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Total Steps:     $totalSteps" -ForegroundColor White
Write-Host "Total Errors:    $errors" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
Write-Host "Total Time:      $([math]::Round($totalTime, 2)) seconds ($([math]::Round($totalTime / 60, 2)) minutes)" -ForegroundColor White
Write-Host "Error Rate:      $([math]::Round(($errors / $totalSteps) * 100, 2))%" -ForegroundColor $(if ($errors -gt 0) { "Yellow" } else { "Green" })
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Detailed log saved to: $logFile" -ForegroundColor Yellow
Write-Host ""

