# Ymyzon - CI/CD Deployment Comparison Project

Microservices system demonstrating manual vs automated deployment approaches for SIN synopsis.

---

## 📊 Project Purpose

Compare **three deployment approaches** empirically:
1. **Manual** - 13 steps, 196s average (baseline)
2. **Local Docker** - 1 command, 54s average (72.45% faster)
3. **GitHub Actions** - 1 push, ~120s average (40% faster)

---

## 🏗️ System Architecture

**Services:**
- **OrderService** - REST API for order management (.NET 9)
- **InventoryService** - REST API for inventory tracking (.NET 9)
- **RabbitMQ** - Message broker for async communication

**Flow:** OrderService publishes order events → RabbitMQ → InventoryService updates inventory

**Ports:**
- OrderService: `http://localhost:5194`
- InventoryService: `http://localhost:5219`
- RabbitMQ UI: `http://localhost:15672` (guest/guest)

---

## 🚀 Quick Start

### Fastest Way (Local Docker)
```bash
cd Scripts
bash start-all.sh        # Starts everything
bash test-services.sh    # Verify working
```

### Measurement Mode
```bash
cd Scripts
bash compare-deployments.sh  # Run full comparison
```

### GitHub Actions (Automatic)
```bash
git push origin main  # Triggers CI/CD automatically
# View at: https://github.com/your-repo/actions
```

---

## 📁 Project Structure

```
Ymyzon/
├── OrderService/          # Order management API
├── InventoryService/      # Inventory management API
├── Scripts/               # All deployment scripts
│   ├── start-all.sh      # Quick start (automated)
│   ├── manual-deploy-test.sh   # Measure manual deployment
│   ├── docker-deploy.sh        # Measure automated deployment
│   ├── compare-deployments.sh  # Full comparison
│   └── cleanup-all.sh          # Clean everything
├── docker-compose.yml     # Service orchestration
└── README.md             # This file

Repository Root/
├── .github/workflows/    # GitHub Actions CI/CD
├── Ymyzon/              # This project
└── SYNOPSIS_GUIDE.md    # Synopsis writing guide
```

---

## 🎯 Deployment Approaches

### 1. Manual Deployment
**Purpose:** Baseline measurement  
**Time:** 196s average  
**Steps:** 13 manual actions  
**Command:** `bash Scripts/manual-deploy-test.sh`

**Use case:** Understanding system complexity

### 2. Local Docker Automation
**Purpose:** Fast development iteration  
**Time:** 54s average (72.45% improvement)  
**Steps:** 1 command  
**Command:** `bash Scripts/docker-deploy.sh`

**Use case:** Local development and testing

### 3. GitHub Actions CI/CD
**Purpose:** Team collaboration  
**Time:** ~120s (40% improvement)  
**Steps:** 1 git push  
**Location:** `.github/workflows/`

**Use case:** Continuous integration, team projects

---

## 🧪 Testing

### Health Checks
```bash
cd Scripts
bash test-services.sh
```

### Integration Test
```bash
cd Scripts
bash test-create-order.sh
# Creates order, verifies inventory update
```

### Full System Test (Docker)
```bash
cd Scripts
bash test-docker.sh
```

---

## 📊 Measurement Results

| Approach | Avg Time | Steps | Consistency | Best For |
|----------|----------|-------|-------------|----------|
| Manual | 196s | 13 | Low (105s var) | Learning |
| Local Docker | 54s | 1 | High (3s var) | Fast iteration |
| GitHub Actions | ~120s | 1 | High (~10s var) | Team CI/CD |

**Key Findings:**
- ⚡ 72.45% time reduction with local automation
- 🎯 35x consistency improvement with automation
- 🔧 92.3% complexity reduction (13 steps → 1 command)
- 💰 9.48 hours saved per year (240 deployments)

See `RESULTS_SUMMARY.md` for detailed data.

---

## 🛠️ Common Commands

### Start Services
```bash
cd Scripts
bash start-all.sh          # Interactive (new windows)
bash start-background.sh   # Background processes
```

### Run Measurements
```bash
bash manual-deploy-test.sh      # Test manual approach
bash docker-deploy.sh           # Test automated approach
bash compare-deployments.sh     # Compare all approaches
```

### Cleanup
```bash
bash cleanup-all.sh        # Remove all containers
bash stop-services.sh      # Stop running services
```

---

## 📖 Documentation

- **README.md** (this file) - Quick reference
- **RESULTS_SUMMARY.md** - Detailed measurement data
- **../SYNOPSIS_GUIDE.md** - Complete synopsis writing guide
- **Scripts/MEASUREMENTS.md** - Measurement methodology

---

## 🔧 Troubleshooting

### Services won't start
```bash
cd Scripts
bash cleanup-all.sh  # Clean everything
bash start-all.sh    # Try again
```

### Port conflicts
Check for existing containers:
```bash
docker ps -a
docker stop $(docker ps -aq)  # Stop all
docker rm $(docker ps -aq)    # Remove all
```

### Docker Compose not found
Use V2 syntax: `docker compose` (not `docker-compose`)

### GitHub Actions not triggering
- Workflows must be at `.github/workflows/` (repository root)
- Check GitHub → Settings → Actions → Allowed

---

## 🎓 For Synopsis

This project provides empirical data for CI/CD deployment comparison:

1. **Run measurements:** `bash Scripts/compare-deployments.sh`
2. **Collect GitHub Actions data:** Push to main, download artifacts
3. **Use the data:** See `RESULTS_SUMMARY.md` for synopsis integration
4. **Write synopsis:** Follow `../SYNOPSIS_GUIDE.md`

**Key metrics to cite:**
- 72.45% time improvement (manual → local automation)
- 92.3% complexity reduction (13 steps → 1 command)
- 35x consistency improvement (variance: 105s → 3s)

---

## 📝 Notes

- **Date:** December 2025
- **Course:** SIN (System Integration)
- **Purpose:** Synopsis empirical comparison
- **Status:** ✅ Complete, ready for writing

---

**Quick command to get started:**
```bash
cd Ymyzon/Scripts && bash start-all.sh
```

For detailed measurement data and synopsis guidance, see the other documentation files.

