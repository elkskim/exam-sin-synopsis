#!/bin/bash

# Manual Deployment Measurement Script
# Records timing and errors for manual deployment process

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="../manual-deployment-log-$TIMESTAMP.txt"

echo "========================================"
echo "Manual Deployment Measurement"
echo "========================================"
echo ""
echo "This script will guide you through manual deployment"
echo "and measure the time for each step."
echo ""
echo "Results will be saved to: $LOG_FILE"
echo ""
read -p "Press Enter to begin..."
echo ""

# Record overall start time
overall_start=$(date +%s)

# Initialize counters
total_steps=0
errors=0

# Log function
log_event() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Step timing function
start_step() {
    step_start=$(date +%s)
    total_steps=$((total_steps + 1))
    log_event "[$total_steps] $1"
    echo "Action: $2"
    echo ""
}

end_step() {
    step_end=$(date +%s)
    step_time=$((step_end - step_start))
    log_event "    Duration: $step_time seconds"
    log_event ""
}

# Error recording function
record_error() {
    errors=$((errors + 1))
    log_event "    ⚠️  ERROR: $1"
    read -p "    Did you resolve it? (y/n): " resolved
    if [[ $resolved =~ ^[Yy]$ ]]; then
        log_event "    ✓ Error resolved"
    else
        log_event "    ✗ Error not resolved"
    fi
    log_event ""
}

log_event "========================================="
log_event "Manual Deployment Test - $TIMESTAMP"
log_event "========================================="
log_event ""

# STEP 1: Stop existing services
start_step "Stop existing services" "Manually stop any running services (Ctrl+C in terminals, docker stop, etc.)"
read -p "Press Enter when services are stopped..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 2: Clean Docker containers
start_step "Clean Docker containers" "Run: docker-compose down -v"
read -p "Press Enter when complete..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 2.5: Remove existing RabbitMQ container
start_step "Remove existing RabbitMQ container (if any)" "Run: docker stop rabbitmq && docker rm rabbitmq (ignore errors if container doesn't exist)"
read -p "Press Enter when complete..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 3: Start RabbitMQ
start_step "Start RabbitMQ" "Run: docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management"
read -p "Press Enter when RabbitMQ is started..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 4: Wait for RabbitMQ
start_step "Wait for RabbitMQ initialization" "Wait ~15 seconds for RabbitMQ to be ready"
read -p "Press Enter when RabbitMQ is ready..."
end_step

# STEP 5: Navigate to InventoryService
start_step "Navigate to InventoryService directory" "Run: cd InventoryService"
read -p "Press Enter when complete..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 6: Start InventoryService
start_step "Start InventoryService" "Open new terminal and run: dotnet run"
read -p "Press Enter when service is running..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 7: Navigate to OrderService
start_step "Navigate to OrderService directory" "Run: cd ../OrderService"
read -p "Press Enter when complete..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 8: Start OrderService
start_step "Start OrderService" "Open new terminal and run: dotnet run"
read -p "Press Enter when service is running..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 9: Wait for services
start_step "Wait for services to initialize" "Wait for both services to show 'Now listening on' messages"
read -p "Press Enter when both services are ready..."
end_step

# STEP 10: Test InventoryService
start_step "Test InventoryService health" "Run: curl http://localhost:5219/api/inventory/health"
read -p "Press Enter when complete..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 11: Test OrderService
start_step "Test OrderService health" "Run: curl http://localhost:5194/api/order/health"
read -p "Press Enter when complete..."
read -p "Did you encounter any errors? (y/n): " had_error
if [[ $had_error =~ ^[Yy]$ ]]; then
    read -p "Describe error: " error_desc
    record_error "$error_desc"
fi
end_step

# STEP 12: Test order creation
start_step "Test order creation" "Run test script to create an order and verify inventory update"
read -p "Press Enter when test is complete..."
read -p "Did the test pass? (y/n): " test_passed
if [[ ! $test_passed =~ ^[Yy]$ ]]; then
    read -p "Describe issue: " error_desc
    record_error "$error_desc"
fi
end_step

# Calculate totals
overall_end=$(date +%s)
total_time=$((overall_end - overall_start))

# Summary
log_event "========================================="
log_event "Manual Deployment Summary"
log_event "========================================="
log_event "Total Steps:     $total_steps"
log_event "Total Errors:    $errors"
log_event "Total Time:      $total_time seconds ($((total_time / 60)) minutes)"
log_event "Error Rate:      $((errors * 100 / total_steps))%"
log_event "========================================="

echo ""
echo "========================================="
echo "Manual Deployment Complete!"
echo "========================================="
echo "Total Steps:     $total_steps"
echo "Total Errors:    $errors"
echo "Total Time:      $total_time seconds ($((total_time / 60)) minutes)"
echo "Error Rate:      $((errors * 100 / total_steps))%"
echo "========================================="
echo ""
echo "Detailed log saved to: $LOG_FILE"
echo ""

