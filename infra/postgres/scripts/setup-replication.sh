#!/usr/bin/env bash
# ===================================================================
# setup-replication.sh
# ===================================================================
# Purpose:
#   Automate setting up streaming replication from primary to standby.
#
# Steps:
#   1. Create replication slot on primary
#   2. Take base backup from primary using pg_basebackup
#   3. Configure recovery settings (standby.signal, primary_conninfo)
#   4. Start standby server
#   5. Verify replication status
# ===================================================================

set -euo pipefail

# -----------------------------
# CONFIGURATION (adjust as needed)
# -----------------------------
PRIMARY_HOST="primary-db"
PRIMARY_PORT=5432
PRIMARY_USER="replicator"
REPLICATION_SLOT="standby_slot"
STANDBY_DATA_DIR="/var/lib/postgresql/data"
PG_BASEBACKUP_OPTS="-R -X stream -C -S ${REPLICATION_SLOT} --progress"

# -----------------------------
# HELPER FUNCTIONS
# -----------------------------
log() {
  echo -e "[INFO] $*"
}

error_exit() {
  echo -e "[ERROR] $*" >&2
  exit 1
}

# -----------------------------
# 1. Create replication slot on primary
# -----------------------------
log "Creating replication slot '${REPLICATION_SLOT}' on primary..."
if ! psql -h "${PRIMARY_HOST}" -p "${PRIMARY_PORT}" -U "${PRIMARY_USER}" -d postgres \
  -c "SELECT * FROM pg_create_physical_replication_slot('${REPLICATION_SLOT}');" >/dev/null 2>&1; then
  error_exit "Failed to create replication slot. Check primary connectivity and permissions."
fi
log "Replication slot '${REPLICATION_SLOT}' created successfully."

# -----------------------------
# 2. Take base backup from primary
# -----------------------------
log "Taking base backup from primary into ${STANDBY_DATA_DIR}..."
rm -rf "${STANDBY_DATA_DIR:?}"/*
if ! pg_basebackup -h "${PRIMARY_HOST}" -p "${PRIMARY_PORT}" -U "${PRIMARY_USER}" \
  -D "${STANDBY_DATA_DIR}" ${PG_BASEBACKUP_OPTS}; then
  error_exit "Base backup failed."
fi
log "Base backup completed successfully."

# -----------------------------
# 3. Configure recovery settings
# -----------------------------
log "Configuring standby recovery settings..."
cat > "${STANDBY_DATA_DIR}/postgresql.auto.conf" <<EOF
primary_conninfo = 'host=${PRIMARY_HOST} port=${PRIMARY_PORT} user=${PRIMARY_USER} application_name=standby1'
primary_slot_name = '${REPLICATION_SLOT}'
EOF

# Create standby.signal file
touch "${STANDBY_DATA_DIR}/standby.signal"
log "Standby configured with primary_conninfo and standby.signal."

# -----------------------------
# 4. Start standby server
# -----------------------------
log "Starting standby PostgreSQL server..."
if ! pg_ctl -D "${STANDBY_DATA_DIR}" -w start; then
  error_exit "Failed to start standby server."
fi
log "Standby server started successfully."

# -----------------------------
# 5. Verify replication status
# -----------------------------
log "Verifying replication status..."
if ! psql -h localhost -p "${PRIMARY_PORT}" -U postgres -d postgres \
  -c "SELECT status, sent_lsn, write_lsn, flush_lsn, replay_lsn FROM pg_stat_replication;" ; then
  error_exit "Failed to verify replication status."
fi

log "Replication setup completed successfully!"
