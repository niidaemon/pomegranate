#!/usr/bin/env bash
set -e

echo "⏳ Loading schemas into databases....."

psql -v ON_ERROR_STOP=1 \
     -U "$POSTGRES_USER" \
     -d auth_db \
     -f /docker-entrypoint-initdb.d/auth-schema.sql

psql -v ON_ERROR_STOP=1 \
     -U "$POSTGRES_USER" \
     -d catalog_db \
     -f /docker-entrypoint-initdb.d/catalog-schema.sql

psql -v ON_ERROR_STOP=1 \
     -U "$POSTGRES_USER" \
     -d inventory_db \
     -f /docker-entrypoint-initdb.d/catalog-schema.sql


echo "✅ Schemas loaded successfully....."
