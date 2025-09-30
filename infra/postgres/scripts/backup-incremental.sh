#!/usr/bin/env bash
# ===================================================================
# Incremental Backup Script (pgBackRest)
# ===================================================================
# Purpose:
#   Run an incremental backup of the PostgreSQL cluster using pgBackRest.
# ===================================================================

set -euo pipefail

LOG_FILE="/var/log/pgbackrest/backup-incremental.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[INFO] Starting incremental backup at $(date)"

if pgbackrest --stanza=main --type=incr backup; then
  echo "[INFO] Incremental backup completed successfully."
else
  echo "[ERROR] Incremental backup failed!" >&2
  exit 1
fi

echo "[INFO] Incremental backup finished at $(date)"
