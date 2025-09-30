#!/usr/bin/env bash
# ===================================================================
# Health Check Script
# ===================================================================
# Purpose:
#   Validate the health of the PostgreSQL HA infrastructure:
#     - PostgreSQL primary
#     - PostgreSQL standbys
#     - Replication
#     - PgBouncer
#     - HAProxy
#     - Databases and service users
#     - Backup recency
#     - Disk space
# ===================================================================

set -euo pipefail

# -----------------------------
# Colors
# -----------------------------
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }

# -----------------------------
# Config
# -----------------------------
PRIMARY_HOST="postgres-primary"
STANDBY1_HOST="postgres-standby-1"
STANDBY2_HOST="postgres-standby-2"
PGBOUNCER_HOST="pgbouncer"
HAPROXY_HOST="haproxy"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-password}" # password here
DATABASES=("auth_db" "catalog_db" "cart_db" "orders_db" "inventory_db" "payments_db" "analytics_db" "deliveries_db" "notifications_db")
SERVICE_USERS=("auth_service" "catalog_service" "cart_service" "orders_service" "inventory_service" "payments_service" "analytics_service" "exporter")

# -----------------------------
# Checks
# -----------------------------

# 1. PostgreSQL primary is running
if pg_isready -h "$PRIMARY_HOST" -U "$POSTGRES_USER" >/dev/null 2>&1; then
  pass "PostgreSQL primary is running"
else
  fail "PostgreSQL primary is not responding"
fi

# 2. PostgreSQL standbys are running
for standby in "$STANDBY1_HOST" "$STANDBY2_HOST"; do
  if pg_isready -h "$standby" -U "$POSTGRES_USER" >/dev/null 2>&1; then
    pass "PostgreSQL standby $standby is running"
  else
    fail "PostgreSQL standby $standby is not responding"
  fi
done

# 3. Replication is working
if psql -h "$PRIMARY_HOST" -U "$POSTGRES_USER" -d postgres -tAc \
   "SELECT count(*) FROM pg_stat_replication;" | grep -q '^[1-9]'; then
  pass "Replication is working"
else
  fail "Replication is not active"
fi

# 4. PgBouncer is responding
if psql -h "$PGBOUNCER_HOST" -p 6432 -U "$POSTGRES_USER" -d auth_db -c "SELECT 1;" >/dev/null 2>&1; then
  pass "PgBouncer is responding"
else
  fail "PgBouncer is not responding"
fi

# 5. HAProxy is healthy
if nc -z "$HAPROXY_HOST" 5432 && nc -z "$HAPROXY_HOST" 5433; then
  pass "HAProxy is healthy (ports 5432/5433 open)"
else
  fail "HAProxy is not healthy"
fi

# 6. All databases exist
for db in "${DATABASES[@]}"; do
  if psql -h "$PRIMARY_HOST" -U "$POSTGRES_USER" -d postgres -tAc \
     "SELECT 1 FROM pg_database WHERE datname='${db}';" | grep -q 1; then
    pass "Database $db exists"
  else
    fail "Database $db missing"
  fi
done

# 7. All service users can connect
for user in "${SERVICE_USERS[@]}"; do
  if PGPASSWORD="change_me" psql -h "$PRIMARY_HOST" -U "$user" -d "${DATABASES[0]}" -c "SELECT 1;" >/dev/null 2>&1; then
    pass "Service user $user can connect"
  else
    fail "Service user $user cannot connect"
  fi
done

# 8. Backup is recent (< 24 hours)
if pgbackrest --stanza=main info | grep -q "full"; then
  LAST_BACKUP=$(pgbackrest --stanza=main info --output=json | jq -r '.[0].backup[-1].timestamp.stop')
  NOW=$(date +%s)
  if (( NOW - LAST_BACKUP < 86400 )); then
    pass "Backup is recent (< 24 hours)"
  else
    fail "Backup is older than 24 hours"
  fi
else
  fail "No backups found"
fi

# 9. Disk space is sufficient (>20% free)
DISK_FREE=$(df /var/lib/postgresql/data | awk 'NR==2 {print $5}' | sed 's/%//')
if (( DISK_FREE < 80 )); then
  pass "Disk space is sufficient"
else
  fail "Disk space is low (<20% free)"
fi
