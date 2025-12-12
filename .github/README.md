# GitHub Actions Workflows

This directory contains CI/CD workflows for the exam-sin-synopsis project.

## Workflows

### `ci-cd.yml`
Standard CI/CD pipeline that runs on every push and pull request to main/develop branches.

### `measure-cicd.yml`
Performance measurement pipeline that tracks deployment times for synopsis data comparison.

## Project Structure

The workflows operate on the Ymyzon microservices system located in the `Ymyzon/` directory:
- `Ymyzon/InventoryService/` - Inventory management service
- `Ymyzon/OrderService/` - Order management service  
- `Ymyzon/docker-compose.yml` - Service orchestration

## Usage

**Automatic trigger:** Push to `main` or `develop` branches

**Manual trigger:**
1. Go to repository → Actions tab
2. Select workflow → Run workflow

## Results

Performance reports are saved as artifacts and can be downloaded from the workflow run page.

See `Ymyzon/GITHUB_ACTIONS_GUIDE.md` for detailed documentation.

