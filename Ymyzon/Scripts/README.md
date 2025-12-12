# Scripts Directory Migration - Summary

## What Changed

All script files have been moved from `Ymyzon/` to `Ymyzon/Scripts/` directory.

### Files Moved
- `start-all.sh`
- `start-all.ps1`
- `start-all.bat`
- `start-background.sh`
- `stop-services.sh`
- `test-services.sh`
- `test-services.ps1`
- `test-create-order.sh`
- `test-create-order.ps1`
- `test-docker.sh`
- `test-docker.ps1`
- `test-manual.sh`

## Path Updates

All scripts have been refactored to use the correct paths:

### Key Changes:
1. **Service paths**: Scripts now use `$YMYZON_ROOT` (parent directory) to reference services
   - `$YMYZON_ROOT/InventoryService`
   - `$YMYZON_ROOT/OrderService`

2. **Output files**: Saved to Ymyzon root instead of Scripts directory
   - PID files (`.inventory.pid`, `.order.pid`)
   - Log files (`inventory-service.log`, `order-service.log`)
   - Test output JSON files

3. **Documentation**: README.md and QUICK_START.md updated with correct paths

## How to Use

### From Ymyzon directory:
```bash
cd Scripts
bash start-all.sh
```

### From Scripts directory:
```bash
bash start-all.sh
```

The scripts automatically detect their location and reference the parent directory for service files.

## Files Updated

### Scripts with path changes:
- ✅ `start-all.sh` - Updated service paths to use `$YMYZON_ROOT`
- ✅ `start-all.bat` - Updated to use `%~dp0..\` for parent directory
- ✅ `start-background.sh` - Updated service and log paths
- ✅ `stop-services.sh` - Updated PID file paths
- ✅ `test-manual.sh` - Updated output file paths

### Scripts without path changes (still work):
- ✅ `test-services.sh` - Uses HTTP endpoints only
- ✅ `test-services.ps1` - Uses HTTP endpoints only
- ✅ `test-create-order.sh` - Uses HTTP endpoints only
- ✅ `test-create-order.ps1` - Uses HTTP endpoints only
- ✅ `test-docker.sh` - Uses HTTP endpoints only

### Documentation updated:
- ✅ `README.md` - Updated all script references
- ✅ `QUICK_START.md` - Updated all script references and examples

## Testing

Path resolution has been verified:
- `SCRIPT_DIR` correctly points to `Ymyzon/Scripts`
- `YMYZON_ROOT` correctly points to `Ymyzon`
- Service directories are accessible from Scripts directory

