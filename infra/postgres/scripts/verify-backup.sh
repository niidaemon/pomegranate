#!/usr/bin/env bash
# ===================================================================
# Backup Verification Script (pgBackRest)
# ===================================================================
# Purpose:
#   Verify that backups are valid and restorable.
#   Steps:
#     1. Check latest backup info
#     2. Verify backup integrity
#     3. Test restore to temporary location
# ===================================================================

set -euo pipefail

LOG_FILE="/var/log/pgbackrest/verify-backup.log"
TEMP_RESTORE="/tmp/pgbackrest-restore-test"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "[INFO] Starting backup verification at $(date)"

# Step 1: Check latest backup info
echo "[INFO] Checking backup info..."
pgbackrest --stanza=main info || {
  echo "[ERROR] Failed to retrieve backup info." >&2
  exit 1
}

# Step 2: Verify backup integrity
echo "[INFO] Verifying backup integrity..."
pgbackrest --stanza=main check || {
  echo "[ERROR] Backup integrity check failed!" >&2
  exit 1
}

# Step 3: Test restore to temporary location
echo "[INFO] Testing restore to ${TEMP_RESTORE}..."
rm -rf "${TEMP_RESTORE}"
mkdir -p "${TEMP_RESTORE}"

if pgbackrest --stanza=main restore --delta --target-path="${TEMP_RESTORE}" --type=default --log-level-console=info --log-level-file=debug --log-path=/var/log/pgbackrest; then
  echo "[INFO] Restore test completed successfully."
else
  echo "[ERROR] Restore test failed!" >&2
  exit 1
fi

# Cleanup
rm -rf "${TEMP_RESTORE}"

echo "[INFO] Backup verification finished at $(date)"
