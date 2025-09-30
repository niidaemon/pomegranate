#!/usr/bin/env bash
# ===================================================================
# Flyway Migration Runner Script
# ===================================================================
# Purpose:
#   Wrap Flyway commands with error handling and logging.
#   Provides the following functions:
#     - migrate  : Run all pending migrations
#     - info     : Show migration status
#     - validate : Validate applied migrations
#     - repair   : Repair failed migrations
# ===================================================================

set -euo pipefail

LOG_FILE="/var/log/flyway/migrations.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# -----------------------------
# Helper Functions
# -----------------------------
usage() {
  echo "Usage: $0 {migrate|info|validate|repair}"
  exit 1
}

error_exit() {
  echo "[ERROR] $1" >&2
  exit 1
}

check_flyway() {
  if ! command -v flyway >/dev/null 2>&1; then
    error_exit "Flyway is not installed or not in PATH."
  fi
}

# -----------------------------
# Main
# -----------------------------
ACTION="${1:-}"

if [[ -z "$ACTION" ]]; then
  usage
fi

check_flyway

case "$ACTION" in
  migrate)
    echo "[INFO] Running Flyway migrations at $(date)"
    if flyway migrate; then
      echo "[INFO] Migrations applied successfully."
    else
      error_exit "Migration failed."
    fi
    ;;
  info)
    echo "[INFO] Showing Flyway migration status at $(date)"
    flyway info || error_exit "Failed to retrieve migration info."
    ;;
  validate)
    echo "[INFO] Validating Flyway migrations at $(date)"
    if flyway validate; then
      echo "[INFO] Validation successful."
    else
      error_exit "Validation failed."
    fi
    ;;
  repair)
    echo "[INFO] Repairing Flyway metadata at $(date)"
    if flyway repair; then
      echo "[INFO] Repair completed successfully."
    else
      error_exit "Repair failed."
    fi
    ;;
  *)
    usage
    ;;
esac
