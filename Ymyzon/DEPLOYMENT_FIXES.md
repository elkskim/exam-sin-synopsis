# Deployment Issues Fixed - December 12, 2025

## Issues Identified

### 1. **Mixed PowerShell/Bash Code in docker-deploy.sh**
**Problem:** PowerShell code was incorrectly appended to the bash script, causing syntax errors:
```
docker-deploy.sh: line 88: Write-Host: command not found
docker-deploy.sh: line 107: syntax error near unexpected token `('
```

**Solution:** Removed all PowerShell code from docker-deploy.sh. PowerShell version exists separately as docker-deploy.ps1.

---

### 2. **RabbitMQ Port Conflict**
**Problem:** Deployment failed because port 5672 was already allocated by an existing RabbitMQ container:
```
Error: Bind for 0.0.0.0:5672 failed: port is already allocated
```

This happened because:
- Previous deployments created a standalone `rabbitmq` container
- The cleanup script (`docker-compose down`) only removes docker-compose managed containers
- The standalone RabbitMQ container persists across deployments

**Solution:** Enhanced cleanup to detect and remove standalone RabbitMQ containers:

```bash
# Check for standalone RabbitMQ container
if docker ps -a --format '{{.Names}}' | grep -q '^rabbitmq$'; then
    echo "Removing standalone RabbitMQ container..."
    docker stop rabbitmq > /dev/null 2>&1
    docker rm rabbitmq > /dev/null 2>&1
fi
```

---

### 3. **Manual Deployment Test Didn't Account for Existing Containers**
**Problem:** Manual deployment testing assumed a clean slate but didn't guide users to remove existing RabbitMQ containers.

**Solution:** Added explicit step to manual deployment tests:
- Step 2.5: "Remove existing RabbitMQ container (if any)"
- Guides user to run: `docker stop rabbitmq && docker rm rabbitmq`

---

## Files Modified

### ✅ `docker-deploy.sh`
- Removed PowerShell code
- Added standalone RabbitMQ cleanup
- Now properly handles existing containers

### ✅ `manual-deploy-test.sh`
- Added step to remove existing RabbitMQ container
- Now accounts for 13 steps instead of 12

### ✅ `manual-deploy-test.ps1`
- Added step to remove existing RabbitMQ container
- Consistent with bash version

### ✅ `measure.sh`
- Enhanced cleanup option (5) to remove standalone containers
- Better user feedback

### ✅ NEW: `cleanup-all.sh`
- Comprehensive cleanup script
- Removes all Ymyzon-related containers, networks, and volumes
- Removes both docker-compose and standalone containers
- Can be run anytime to ensure clean environment

---

## How to Use

### Before Running Measurements
Always start with a clean environment:

```bash
cd Scripts
bash cleanup-all.sh
```

### Running Automated Deployment
The script now handles cleanup automatically:

```bash
bash docker-deploy.sh
# Automatically removes existing RabbitMQ if found
```

### Running Manual Deployment Test
The script now guides you to remove existing containers:

```bash
bash manual-deploy-test.sh
# Step 2.5 will prompt you to remove RabbitMQ
```

---

## Testing the Fixes

### Test 1: Clean Deployment
```bash
cd Scripts
bash cleanup-all.sh
bash docker-deploy.sh
```

**Expected:** No port conflicts, successful deployment

### Test 2: Multiple Runs
```bash
bash docker-deploy.sh   # First run
bash docker-deploy.sh   # Second run (should cleanup first)
```

**Expected:** Second run successfully removes first run's containers

### Test 3: Mixed Deployment
```bash
bash cleanup-all.sh
bash manual-deploy-test.sh  # Creates standalone RabbitMQ
# Then in another terminal:
bash docker-deploy.sh       # Should remove standalone RabbitMQ
```

**Expected:** No port conflicts

---

## Root Cause Analysis

The issues stemmed from:

1. **File corruption:** PowerShell code was accidentally appended to bash script during file operations

2. **Container lifecycle mismatch:** 
   - Docker Compose creates containers with project prefix (`ymyzon-rabbitmq`)
   - Manual deployment creates standalone container (`rabbitmq`)
   - These are treated as separate containers by Docker
   - `docker-compose down` doesn't remove standalone containers

3. **Incomplete cleanup strategy:** Original cleanup only targeted docker-compose managed resources

---

## Prevention

To avoid these issues in the future:

1. **Always use cleanup-all.sh before testing**
   ```bash
   bash cleanup-all.sh
   ```

2. **Check for port conflicts before starting**
   ```bash
   docker ps -a | grep -E '5672|5194|5219|15672'
   ```

3. **Use consistent container naming**
   - Docker Compose: Managed, prefixed names
   - Manual: Simple names can conflict

4. **Verify script file integrity**
   - Check file size and line count after modifications
   - Test scripts in isolation before integration

---

## Current State

✅ All scripts cleaned and tested
✅ Robust cleanup implemented
✅ Port conflict issues resolved
✅ Manual deployment test updated
✅ Comprehensive cleanup utility added

**Ready for measurement phase!** 🎯

