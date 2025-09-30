#!/usr/bin/env bash
# ===================================================================
# Full Backup Script (pgBackRest)
# ===================================================================
# Purpose:
#   Run a full backup of the PostgreSQL cluster using pgBackRest.
#   Also prints backup info after completion.
# ===================================================================

set -euo pipefail

LOG_FILE="/var/log/pgbackrest/backup-full.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[INFO] Starting full backup at $(date)"

if pgbackrest --stanza=main --type=full backup; then
  echo "[INFO] Full backup completed successfully."
else
  echo "[ERROR] Full backup failed!" >&2
  exit 1
fi

# Show backup info
pgbackrest --stanza=main info || {
  echo "[ERROR] Failed to retrieve backup info." >&2
  exit 1
}

echo "[INFO] Full backup finished at $(date)"
