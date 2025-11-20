#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

export PGPASSWORD="$POSTGRES_PASSWORD"

echo "waiting for postgres..."

until pg_isready -h "$POSTGRES_HOST" -U "$POSTGRES_USER" >/dev/null 2>&1; do
  sleep 1
done

echo "postgres is ready, running migrations..."

for migration in /migrations/*.sql; do
  echo "applying migration: $migration"
  psql \
    -h "$POSTGRES_HOST" \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" \
    -v ON_ERROR_STOP=1 \
    -f "$migration" >/dev/null
done

for function in /migrations/functions/*.sql; do
  echo "creating function: $function"
  psql \
  -h "$POSTGRES_HOST" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -v ON_ERROR_STOP=1 \
  -f "$function" >/dev/null
done

echo "migrations done"