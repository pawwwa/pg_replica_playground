#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="$POSTGRES_PASSWORD"

SLEEP_SECONDS=${1:-1}

echo "worker started with ${SLEEP_SECONDS}s interval"

while true; do
now=$(date '+%Y-%m-%d %H:%M:%S')

psql \
  -h "$POSTGRES_HOST" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -v ON_ERROR_STOP=1 \
  -v ts="$now" \
  -t -A -q <<'SQL' >/dev/null
SELECT change_operation_state_by_time(:'ts'::timestamp);
SQL

echo "changed operations state with time : '$now'"

sleep "$SLEEP_SECONDS"
done

echo "worker shutdown"