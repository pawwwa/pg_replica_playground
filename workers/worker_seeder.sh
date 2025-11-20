#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="$POSTGRES_PASSWORD"

SEED_COUNT=${1:-1}

echo "worker started with ${SEED_COUNT} operations to seed"

psql \
  -h "$POSTGRES_HOST" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -v ON_ERROR_STOP=1 \
  -v count="$SEED_COUNT" \
  -t -A -q <<'SQL' >/dev/null
CALL seed_operations(:'count'::INT);
SQL

echo "${SEED_COUNT} operations seeded"
echo "worker shutdown"