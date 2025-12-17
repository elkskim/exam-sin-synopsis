@echo off
echo ========================================
echo Starting Ymyzon Microservices System
echo ========================================
echo.

echo [1/3] Starting RabbitMQ...
docker start rabbitmq
if errorlevel 1 (
    echo RabbitMQ container not found, creating new one...
    docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
)
echo Waiting for RabbitMQ to initialize...
timeout /t 10 /nobreak > nul
echo RabbitMQ started!
echo.

echo [2/3] Starting InventoryService on port 5219...
start "InventoryService" cmd /k "cd /d %~dp0..\InventoryService && dotnet run"
echo Waiting for InventoryService to start...
timeout /t 8 /nobreak > nul
echo.

echo [3/3] Starting OrderService on port 5194...
start "OrderService" cmd /k "cd /d %~dp0..\OrderService && dotnet run"
echo Waiting for OrderService to start...
timeout /t 8 /nobreak > nul
echo.

echo ========================================
echo All services should now be running!
echo ========================================
echo.
echo Check the service windows for startup logs.
echo.
echo RabbitMQ Management: http://localhost:15672 (guest/guest)
echo InventoryService:    http://localhost:5219/api/inventory/health
echo OrderService:        http://localhost:5194/api/order/health
echo.
echo Press any key to run tests...
pause > nul

echo.
echo Running health checks...
powershell -ExecutionPolicy Bypass -File "%~dp0test-services.ps1"
echo.
pause

