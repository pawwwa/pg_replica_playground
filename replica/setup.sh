#!/usr/bin/env bash
set -euo pipefail

HOST="${POSTGRES_HOST:-replica}"
USER="${POSTGRES_USER:-postgres}"
PASSWORD="${POSTGRES_PASSWORD:-postgres}"
DB="${POSTGRES_DB:-replica}"

export PGPASSWORD="$PASSWORD"

echo "waiting for replica..."

until pg_isready -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$DB" >/dev/null 2>&1; do
  sleep 1
done

psql -h "$HOST" -U "$USER" -d "$DB" -v ON_ERROR_STOP=1 <<'SQL'
CREATE TABLE IF NOT EXISTS operations (
    id              bigserial       NOT NULL,
    operation_date  date            NOT NULL,
    operation_sum   NUMERIC(12, 2)  NOT NULL,
    state           boolean         NOT NULL,
    operation_uuid  uuid            NOT NULL,
    message         jsonb           NOT NULL,
    PRIMARY KEY (operation_date, id),
    UNIQUE (operation_date, operation_uuid)
)PARTITION BY RANGE (operation_date);

CREATE TABLE IF NOT EXISTS operations_default
    PARTITION OF operations
    DEFAULT;

CREATE TABLE IF NOT EXISTS operations_2025_08
    PARTITION OF operations
    FOR VALUES FROM ('2025-08-01') TO ('2025-9-01');

CREATE TABLE IF NOT EXISTS operations_2025_09
    PARTITION OF operations
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

CREATE TABLE IF NOT EXISTS operations_2025_10
    PARTITION OF operations
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

CREATE TABLE IF NOT EXISTS operations_2025_11
    PARTITION OF operations
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
SQL

psql -h "$HOST" -U "$USER" -d "$DB" -v ON_ERROR_STOP=1 <<SQL
CREATE SUBSCRIPTION operations_sub
CONNECTION 'host=${PRIMARY_HOST} port=${PRIMARY_PORT} dbname=${PRIMARY_DB} user=${PRIMARY_USER} password=${PRIMARY_PASSWORD}'
PUBLICATION operations_pub
WITH (copy_data = true);
SQL


echo "Replica setup completed."
