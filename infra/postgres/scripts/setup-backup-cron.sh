#!/usr/bin/env bash
# ===================================================================
# Setup Backup Cron Jobs
# ===================================================================
# Purpose:
#   Configure cron jobs for automated PostgreSQL backups using pgBackRest.
#   - Daily full backup at 2 AM
#   - Incremental backup every 6 hours
#   - Weekly backup verification on Sunday at 3 AM
# ===================================================================

set -euo pipefail

CRON_FILE="/etc/cron.d/pgbackrest-backups"
LOG_FILE="/var/log/pgbackrest/setup-cron.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "[INFO] Setting up backup cron jobs at $(date)"

# -----------------------------
# Validate cron installation
# -----------------------------
if ! command -v cron >/dev/null 2>&1 && ! command -v crond >/dev/null 2>&1; then
  echo "[ERROR] cron is not installed. Please install it first." >&2
  exit 1
fi
echo "[INFO] Cron is installed."

# -----------------------------
# Write cron jobs
# -----------------------------
echo "[INFO] Writing cron jobs to ${CRON_FILE}"

cat > "$CRON_FILE" <<EOF
# ===================================================================
# pgBackRest Backup Cron Jobs
# ===================================================================
# Daily full backup at 2 AM
0 2 * * * root /scripts/backup-full.sh >> /var/log/pgbackrest/backup-full-cron.log 2>&1

# Incremental backup every 6 hours
0 */6 * * * root /scripts/backup-incremental.sh >> /var/log/pgbackrest/backup-incremental-cron.log 2>&1

# Weekly backup verification on Sunday at 3 AM
0 3 * * 0 root /scripts/verify-backup.sh >> /var/log/pgbackrest/verify-backup-cron.log 2>&1
EOF

# -----------------------------
# Apply cron jobs
# -----------------------------
echo "[INFO] Reloading cron service..."
if command -v systemctl >/dev/null 2>&1; then
  systemctl restart cron || systemctl restart crond || true
else
  service cron restart || service crond restart || true
fi

echo "[INFO] Backup cron jobs successfully configured."
