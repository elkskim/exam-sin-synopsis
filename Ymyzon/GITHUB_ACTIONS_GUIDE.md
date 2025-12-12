# GitHub Actions CI/CD Pipeline Guide

## Overview

This repository now includes **GitHub Actions workflows** for automated CI/CD deployment, adding a third comparison point to your synopsis data.

---

## Available Workflows

### 1. `ci-cd.yml` - Standard CI/CD Pipeline
**Trigger:** Push to `main` or `develop`, pull requests, manual dispatch

**What it does:**
- ✅ Checks out code
- ✅ Sets up .NET 9
- ✅ Restores dependencies
- ✅ Builds services
- ✅ Runs tests
- ✅ Builds Docker images
- ✅ Deploys services
- ✅ Runs health checks
- ✅ Runs integration tests
- ✅ Reports success/failure

**Use case:** Standard CI/CD for every commit

---

### 2. `measure-cicd.yml` - Performance Measurement Pipeline ⏱️
**Trigger:** Push to `main` or `develop`, manual dispatch

**What it does:** Everything in `ci-cd.yml` PLUS:
- ⏱️ **Measures time for each phase**
- 📊 **Generates performance report**
- 📈 **Compares to manual/local deployment**
- 💾 **Saves artifacts for analysis**

**Use case:** Gathering CI/CD performance data for synopsis

---

## Setup Instructions

### Step 1: Commit and Push Workflows

The workflows are already created in `.github/workflows/`. Just commit them:

```bash
cd "C:\Users\elksk\Documents\rimeligt legit skolesager\Programmeringsprojekter\SIN\exam-sin-synopsis"
git add Ymyzon/.github/workflows/
git commit -m "Add GitHub Actions CI/CD pipelines"
git push origin main
```

### Step 2: Verify Workflows Appear in GitHub

1. Go to your repository on GitHub
2. Click the **"Actions"** tab
3. You should see both workflows listed

---

## Running the Measurement Workflow

### Option A: Automatic (on Push)
Simply push any change to `main` or `develop`:

```bash
# Make a small change (e.g., update README)
git commit --allow-empty -m "Trigger CI/CD measurement"
git push origin main
```

The workflow will automatically run!

---

### Option B: Manual Trigger
1. Go to **GitHub → Actions**
2. Click **"CI/CD with Performance Measurement"**
3. Click **"Run workflow"** dropdown
4. Select branch (main)
5. Click **"Run workflow"** button

---

## Viewing Results

### In the GitHub Actions UI:

1. Go to **Actions** tab
2. Click on the latest workflow run
3. Click on the job **"Measure CI/CD Deployment Time"**
4. Expand each step to see timing

### Performance Report:

The workflow creates an artifact with performance data:

1. Scroll to bottom of workflow run page
2. Find **"Artifacts"** section
3. Download **"cicd-performance-report"**
4. Open `cicd-performance.txt` to see detailed metrics

---

## Expected Results

Based on typical GitHub Actions runner performance:

### Phase Breakdown (Estimated):
- **Build:** 20-30s (restore + build .NET services)
- **Docker:** 40-60s (build Docker images)
- **Deploy:** 30-40s (start containers + wait)
- **Test:** 5-10s (health checks + integration test)

### Total: ~90-140 seconds

**This gives you three comparison points:**

| Approach | Time | Improvement vs Manual |
|----------|------|----------------------|
| **Manual** | 196s | Baseline |
| **Local Docker** | 54s | 72.45% faster |
| **GitHub Actions** | ~100-120s | ~40-50% faster |

---

## Why GitHub Actions is Slower Than Local Docker

**Local Docker (54s):**
- ✅ Pre-built images may be cached
- ✅ No restore/rebuild if unchanged
- ✅ Local hardware (no network latency)
- ✅ Optimized for speed

**GitHub Actions (100-120s):**
- 🔄 Fresh environment every time
- 🔄 Downloads dependencies from internet
- 🔄 Builds everything from scratch
- 🔄 Shared runner resources
- ✅ BUT: Completely automated (no local setup)
- ✅ AND: Available to entire team
- ✅ AND: Runs on every commit automatically

**The trade-off:** Slightly slower, but:
- No local setup required for team members
- Consistent environment every time
- Automatic on every commit
- Full audit trail and logs
- Integration with GitHub ecosystem

---

## Synopsis Benefits of GitHub Actions

### What This Adds to Your Analysis:

1. **Complete Automation Spectrum:**
   - Manual (196s) → Baseline
   - Local automation (54s) → Best speed, requires local setup
   - Cloud CI/CD (120s) → Balance of speed and team automation

2. **Team Collaboration:**
   - No local Docker/environment setup needed
   - Every team member gets same results
   - Automatic testing on every push

3. **Reproducibility:**
   - Fresh environment every run
   - No "works on my machine" issues
   - Version-controlled infrastructure

4. **Continuous Integration:**
   - Catches issues before merge
   - Automated testing on pull requests
   - Deployment history and rollback

---

## Collecting Data for Synopsis

### Run the Workflow 3-5 Times:

```bash
# Run 1
git commit --allow-empty -m "CI/CD measurement run 1"
git push origin main

# Wait for completion, then:

# Run 2
git commit --allow-empty -m "CI/CD measurement run 2"
git push origin main

# Run 3
git commit --allow-empty -m "CI/CD measurement run 3"
git push origin main
```

### Record the Times:

For each run, note:
- Total time (from workflow summary)
- Build phase time
- Docker phase time
- Deploy phase time
- Test phase time

### Download Artifacts:

Download all `cicd-performance-report` artifacts for your synopsis appendix.

---

## Troubleshooting

### Workflow doesn't appear:
- Make sure files are in `.github/workflows/` directory
- Check YAML syntax is valid
- Ensure you pushed to the correct repository

### Workflow fails:
- Check the logs in GitHub Actions
- Common issues:
  - Port conflicts (unlikely in fresh runner)
  - Timeout waiting for services (increase sleep time)
  - Network issues (GitHub transient issues)

### Build is too slow:
- This is expected on first run
- Subsequent runs may be faster with caching
- Document the time as "cloud CI/CD overhead"

---

## Final Synopsis Comparison Table

After collecting GitHub Actions data, you'll have:

| Metric | Manual | Local Docker | GitHub Actions |
|--------|--------|--------------|----------------|
| **Avg Time** | 196s | 54s | ~120s |
| **Setup Required** | None | Docker + scripts | GitHub repo |
| **Team Access** | Share docs | Share scripts | Automatic |
| **Consistency** | Low (105s var) | High (3s var) | High (~5-10s var) |
| **Automation** | None | Local only | Full (on every push) |
| **Environment** | Manual setup | Local setup | Cloud (no setup) |
| **Best For** | Learning | Fast local deploy | Team collaboration |

---

## Key Synopsis Points

1. **Manual → Local Docker: 72.45% improvement**
   - Best for speed when you control the environment

2. **Manual → GitHub Actions: ~40% improvement**
   - Best for team collaboration and CI/CD
   - Slightly slower than local, but zero setup for team

3. **Trade-off Analysis:**
   - Local Docker: Fastest, but requires local setup
   - GitHub Actions: Automated team access, consistent environment
   - Choice depends on: team size, deployment frequency, environment control

4. **ROI Still Strong:**
   - Even at 120s, GitHub Actions saves 76s per deployment
   - Over 240 deployments/year: 5 hours saved
   - Plus: automated testing, team access, no local setup

---

## Next Steps

1. ✅ Commit and push workflows
2. ✅ Run measurement workflow 3 times
3. ✅ Download performance reports
4. ✅ Record times for comparison table
5. ✅ Include GitHub Actions as "Full CI/CD" in synopsis
6. ✅ Discuss trade-offs: speed vs automation vs team access

**You now have the complete picture: Manual → Local Automation → Cloud CI/CD!** 🚀

