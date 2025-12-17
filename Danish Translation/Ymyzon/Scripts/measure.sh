#!/bin/bash

# Quick measurement runner - simplified interface

echo "========================================="
echo "Ymyzon Deployment Measurement System"
echo "========================================="
echo ""
echo "Choose an option:"
echo ""
echo "1. Run ONE manual deployment test"
echo "2. Run ONE automated deployment test"
echo "3. Run FULL comparison (multiple runs of both)"
echo "4. View latest comparison results"
echo "5. Clean up all deployment containers"
echo ""
read -p "Enter choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "Starting manual deployment measurement..."
        echo ""
        bash manual-deploy-test.sh
        ;;
    2)
        echo ""
        echo "Starting automated deployment measurement..."
        echo ""
        
        # Get Ymyzon root
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"
        
        start=$(date +%s)
        cd "$YMYZON_ROOT"
        
        if docker-compose up -d; then
            echo ""
            echo "Waiting for services to initialize (20 seconds)..."
            sleep 20
            
            echo "Running health checks..."
            cd Scripts
            bash test-docker.sh
            
            end=$(date +%s)
            duration=$((end - start))
            
            echo ""
            echo "========================================="
            echo "Automated Deployment Complete!"
            echo "========================================="
            echo "Total time: ${duration}s ($((duration / 60))m $((duration % 60))s)"
            echo "========================================="
        else
            echo "ERROR: Deployment failed"
        fi
        ;;
    3)
        echo ""
        bash compare-deployments.sh
        ;;
    4)
        echo ""
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"
        
        latest=$(ls -t "$YMYZON_ROOT/deployment-results/comparison-"*.txt 2>/dev/null | head -1)
        
        if [ -f "$latest" ]; then
            echo "Latest comparison results:"
            echo "========================================="
            cat "$latest"
        else
            echo "No comparison results found."
            echo "Run option 3 first to generate comparison data."
        fi
        ;;
    5)
        echo ""
        echo "Cleaning up all containers..."
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        YMYZON_ROOT="$(dirname "$SCRIPT_DIR")"
        cd "$YMYZON_ROOT"
        
        # Stop docker-compose services
        docker-compose down -v 2>/dev/null
        
        # Also remove standalone RabbitMQ
        if docker ps -a --format '{{.Names}}' | grep -q '^rabbitmq$'; then
            echo "Removing standalone RabbitMQ container..."
            docker stop rabbitmq 2>/dev/null
            docker rm rabbitmq 2>/dev/null
        fi
        
        echo "✓ All containers cleaned up"
        echo ""
        echo "You can now run a fresh deployment test."
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""

