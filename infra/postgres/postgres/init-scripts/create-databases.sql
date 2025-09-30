-- ===================================================================
-- PostgreSQL Database Initialization Script
-- ===================================================================
-- This script:
--   1. Installs required extensions
--   2. Creates application databases
--   3. Creates users with appropriate roles
--   4. Grants permissions to service users
-- ===================================================================

-- ===================================================================
-- 1. Extensions (installed in the postgres database by default)
-- ===================================================================
\connect postgres;

-- UUID generation support
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Query statistics collection
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Cryptographic functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ===================================================================
-- 2. Databases
-- ===================================================================
-- Create application-specific databases
CREATE DATABASE auth_db;
CREATE DATABASE catalog_db;
CREATE DATABASE cart_db;
CREATE DATABASE orders_db;
CREATE DATABASE inventory_db;
CREATE DATABASE payments_db;
CREATE DATABASE analytics_db;
CREATE DATABASE deliveries_db;
CREATE DATABASE notifications_db;


-- ====================================================================
-- 3. Users and Roles
-- ====================================================================

-- Replication user (used by standby servers)
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '${POSTGRES_REPLICATION_PASSWORD}';

-- Service users (one per microservice)
CREATE ROLE auth_service       WITH LOGIN PASSWORD '${AUTH_SERVICE_PASSWORD}';
CREATE ROLE catalog_service    WITH LOGIN PASSWORD '${CATALOG_SERVICE_PASSWORD}';
CREATE ROLE cart_service       WITH LOGIN PASSWORD '${CART_SERVICE_PASSWORD}';
CREATE ROLE orders_service     WITH LOGIN PASSWORD '${ORDERS_SERVICE_PASSWORD}';
CREATE ROLE inventory_service  WITH LOGIN PASSWORD '${INVENTORY_SERVICE_PASSWORD}';
CREATE ROLE payments_service   WITH LOGIN PASSWORD '${PAYMENTS_SERVICE_PASSWORD}';
CREATE ROLE analytics_service  WITH LOGIN PASSWORD '${ANALYTICS_SERVICE_PASSWORD}';

-- Prometheus exporter user (monitoring only)
CREATE ROLE exporter WITH LOGIN PASSWORD '${EXPORTER_PASSWORD}';


-- ================================================================
-- 4. Permissions
-- ================================================================
-- Grant each service user access to its own database
\connect auth_db;
GRANT CONNECT ON DATABASE auth_db TO auth_service;
GRANT USAGE ON SCHEMA public TO auth_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO auth_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO auth_service;

\connect catalog_db;
GRANT CONNECT ON DATABASE catalog_db TO catalog_service;
GRANT USAGE ON SCHEMA public TO catalog_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO catalog_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO catalog_service;

\connect cart_db;
GRANT CONNECT ON DATABASE cart_db TO cart_service;
GRANT USAGE ON SCHEMA public TO cart_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cart_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO cart_service;

\connect orders_db;
GRANT CONNECT ON DATABASE orders_db TO orders_service;
GRANT USAGE ON SCHEMA public TO orders_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO orders_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO orders_service;

\connect inventory_db;
GRANT CONNECT ON DATABASE inventory_db TO inventory_service;
GRANT USAGE ON SCHEMA public TO inventory_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO inventory_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO inventory_service;

\connect payments_db;
GRANT CONNECT ON DATABASE payments_db TO payments_service;
GRANT USAGE ON SCHEMA public TO payments_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO payments_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO payments_service;

\connect analytics_db;
GRANT CONNECT ON DATABASE analytics_db TO analytics_service;
GRANT USAGE ON SCHEMA public TO analytics_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO analytics_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO analytics_service;

-- Monitoring user: grant read-only monitoring privileges
\connect postgres;
GRANT pg_monitor TO exporter;

-- ===================================================================
-- End of Initialization Script
-- ===================================================================
