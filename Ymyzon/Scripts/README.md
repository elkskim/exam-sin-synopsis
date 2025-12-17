# Ymyzon Deployment Scripts

This directory contains scripts for deploying, testing, and comparing deployment methods for the Ymyzon microservices application.

## Prerequisites

- Docker and Docker Compose installed
- Bash shell (Git Bash on Windows)
- .NET 8.0 SDK (for manual builds)

## Quick Start

### Start All Services (Automated)
```bash
./start-all.sh
```
Builds and starts all services using Docker Compose.

### Stop All Services
```bash
./stop-services.sh
```
Stops and removes all containers.

### Clean Up Everything
```bash
./cleanup-all.sh
```
Removes all containers, images, volumes, and networks.

## Testing Scripts

### Test Services Health
```bash
./test-services.sh
```
Checks if OrderService and InventoryService are responding correctly.

### Test Order Creation
```bash
./test-create-order.sh
```
Creates a test order and verifies inventory deduction.

### Test Docker Deployment
```bash
./test-docker.sh
```
Full automated deployment test with timing measurements.

### Test Manual Deployment
```bash
./manual-deploy-test.sh
```
Interactive script that guides you through manual deployment while recording timing data.

## Comparative Testing

### Run Full Comparison Test
```bash
./compare-deployments.sh
```

This is the **main test suite** used for the synopsis analysis. It:

1. Runs manual deployment test (interactive)
2. Runs automated Docker deployment test
3. Compares timing results
4. Calculates performance improvements
5. Saves detailed results to `../deployment-results/comparison-TIMESTAMP.txt`

**Usage:**
- Follow the prompts for manual deployment
- Script automatically measures automated deployment
- Results include:
  - Time for each method
  - Performance difference
  - Percentage improvement
  - ROI analysis

### Run Multiple Test Iterations

To collect data for multiple test runs (as done in the synopsis):

```bash
# Run first test
./compare-deployments.sh

# Wait a moment, then run second test
./compare-deployments.sh

# Run third test
./compare-deployments.sh
```

Results are saved with timestamps in `../deployment-results/`.

## Results Location

All test results are saved to:
```
Ymyzon/deployment-results/
├── comparison-YYYYMMDD_HHMMSS.txt    # Comparative test results
├── manual-deployment-log-*.txt       # Manual deployment logs
├── auto-run-*.log                    # Automated deployment logs
└── cicd-performance.txt              # GitHub Actions results
```

## Script Overview

| Script | Purpose |
|--------|---------|
| `start-all.sh` | Start all services with Docker Compose |
| `stop-services.sh` | Stop all running containers |
| `cleanup-all.sh` | Complete cleanup of Docker resources |
| `test-services.sh` | Health check for services |
| `test-create-order.sh` | Order creation test |
| `test-docker.sh` | Automated deployment test |
| `manual-deploy-test.sh` | Manual deployment measurement |
| `compare-deployments.sh` | **Full comparative analysis** |
| `docker-deploy.sh` | Docker deployment helper |
| `measure.sh` | Timing measurement utility |

## Notes

- Scripts expect to be run from the `Scripts/` directory
- Results include timing data, error counts, and ROI calculations
- The `compare-deployments.sh` script is the primary tool for thesis data collection
- Manual tests are interactive and require user input at each step
- Automated tests run unattended and produce consistent results

