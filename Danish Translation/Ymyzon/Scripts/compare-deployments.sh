#!/bin/bash

# Deployment Comparison Script
# Runs both manual and automated deployments multiple times and compares results

echo "========================================="
echo "Deployment Comparison Analysis"
echo "========================================="
echo ""
echo "This script will help you compare:"
echo "  1. Manual deployment (measured interactively)"
echo "  2. Automated deployment (docker-compose)"
echo ""

RESULTS_DIR="../deployment-results"
mkdir -p "$RESULTS_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
COMPARISON_FILE="$RESULTS_DIR/comparison-$TIMESTAMP.txt"

# Create comparison header
cat > "$COMPARISON_FILE" << EOF
========================================
Deployment Comparison Analysis
========================================
Date: $(date)

Test Configuration:
- System: Ymyzon Microservices (2 services + RabbitMQ)
- Services: OrderService, InventoryService
- Messaging: RabbitMQ
- Platform: Docker + .NET 9

========================================
EOF

echo "Results will be saved to: $COMPARISON_FILE"
echo ""

# Ask how many runs
read -p "How many times do you want to test manual deployment? (recommended: 3-5): " manual_runs
read -p "How many times do you want to test automated deployment? (recommended: 3-5): " auto_runs

echo ""
echo "========================================="
echo "Phase 1: Manual Deployment Testing"
echo "========================================="
echo ""
echo "You will perform $manual_runs manual deployment(s)."
echo "Each run will be guided and timed."
echo ""

manual_times=()
manual_errors=()
manual_steps=()

for ((i=1; i<=manual_runs; i++)); do
    echo ""
    echo "--- Manual Run $i of $manual_runs ---"
    read -p "Press Enter to start manual deployment run $i..."
    
    # Run the manual test script
    bash manual-deploy-test.sh
    
    # Get the latest log file
    latest_log=$(ls -t ../manual-deployment-log-*.txt | head -1)
    
    # Extract metrics from log
    time=$(grep "Total Time:" "$latest_log" | awk '{print $3}')
    errors=$(grep "Total Errors:" "$latest_log" | awk '{print $3}')
    steps=$(grep "Total Steps:" "$latest_log" | awk '{print $3}')
    
    manual_times+=($time)
    manual_errors+=($errors)
    manual_steps+=($steps)
    
    echo "Run $i complete: ${time}s, $errors errors"
    
    if [ $i -lt $manual_runs ]; then
        echo ""
        read -p "Ready for next manual run? Press Enter..."
    fi
done

echo ""
echo "========================================="
echo "Phase 2: Automated Deployment Testing"
echo "========================================="
echo ""
echo "Running $auto_runs automated deployment(s)..."
echo ""

auto_times=()
auto_errors=()

for ((i=1; i<=auto_runs; i++)); do
    echo ""
    echo "--- Automated Run $i of $auto_runs ---"
    
    start_time=$(date +%s)
    
    # Run docker-compose deployment
    if bash docker-deploy.sh > "$RESULTS_DIR/auto-run-$i.log" 2>&1; then
        errors=0
    else
        errors=1
    fi
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    auto_times+=($duration)
    auto_errors+=($errors)
    
    echo "Run $i complete: ${duration}s, $errors errors"
    
    # Clean up between runs
    if [ $i -lt $auto_runs ]; then
        echo "Cleaning up..."
        docker-compose down -v > /dev/null 2>&1
        sleep 5
    fi
done

# Calculate statistics
echo ""
echo "========================================="
echo "Calculating Statistics..."
echo "========================================="

# Manual deployment stats
manual_total_time=0
manual_total_errors=0
for time in "${manual_times[@]}"; do
    manual_total_time=$((manual_total_time + time))
done
for err in "${manual_errors[@]}"; do
    manual_total_errors=$((manual_total_errors + err))
done
manual_avg_time=$((manual_total_time / manual_runs))
manual_avg_errors=$(echo "scale=2; $manual_total_errors / $manual_runs" | bc)

# Automated deployment stats
auto_total_time=0
auto_total_errors=0
for time in "${auto_times[@]}"; do
    auto_total_time=$((auto_total_time + time))
done
for err in "${auto_errors[@]}"; do
    auto_total_errors=$((auto_total_errors + err))
done
auto_avg_time=$((auto_total_time / auto_runs))
auto_avg_errors=$(echo "scale=2; $auto_total_errors / $auto_runs" | bc)

# Calculate improvements
time_saved=$((manual_avg_time - auto_avg_time))
time_improvement=$(echo "scale=2; (($manual_avg_time - $auto_avg_time) / $manual_avg_time) * 100" | bc)
error_reduction=$(echo "scale=2; $manual_avg_errors - $auto_avg_errors" | bc)

# Write results to file
cat >> "$COMPARISON_FILE" << EOF

MANUAL DEPLOYMENT RESULTS
========================================
Number of runs:     $manual_runs
Total time:         ${manual_total_time}s
Average time:       ${manual_avg_time}s ($(echo "scale=2; $manual_avg_time / 60" | bc)m)
Total errors:       $manual_total_errors
Average errors:     $manual_avg_errors per run
Steps per deploy:   ${manual_steps[0]}
Human interaction:  Required for all ${manual_steps[0]} steps

Individual runs:
EOF

for ((i=0; i<manual_runs; i++)); do
    echo "  Run $((i+1)): ${manual_times[$i]}s, ${manual_errors[$i]} errors" >> "$COMPARISON_FILE"
done

cat >> "$COMPARISON_FILE" << EOF

AUTOMATED DEPLOYMENT RESULTS
========================================
Number of runs:     $auto_runs
Total time:         ${auto_total_time}s
Average time:       ${auto_avg_time}s ($(echo "scale=2; $auto_avg_time / 60" | bc)m)
Total errors:       $auto_total_errors
Average errors:     $auto_avg_errors per run
Steps automated:    100%
Human interaction:  1 command only

Individual runs:
EOF

for ((i=0; i<auto_runs; i++)); do
    echo "  Run $((i+1)): ${auto_times[$i]}s, ${auto_errors[$i]} errors" >> "$COMPARISON_FILE"
done

cat >> "$COMPARISON_FILE" << EOF

COMPARISON & IMPROVEMENTS
========================================
Time saved:         ${time_saved}s per deployment
Time improvement:   ${time_improvement}% faster
Error reduction:    ${error_reduction} fewer errors per deployment
Consistency:        Automated = reproducible, Manual = variable

Key Findings:
- Automated deployment requires ${time_improvement}% less time
- Reduced from ${manual_steps[0]} manual steps to 1 command
- Human error potential eliminated
- Deployment process is reproducible and consistent

========================================
EOF

# Display results
echo ""
cat "$COMPARISON_FILE"

echo ""
echo "========================================="
echo "Analysis Complete!"
echo "========================================="
echo ""
echo "Full results saved to: $COMPARISON_FILE"
echo ""
echo "You can use this data in your synopsis to demonstrate:"
echo "  ✓ Time savings from automation"
echo "  ✓ Error reduction"
echo "  ✓ Reduced complexity (${manual_steps[0]} steps → 1 command)"
echo "  ✓ Improved consistency"
echo ""

