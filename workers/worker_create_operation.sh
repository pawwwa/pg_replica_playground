#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="$POSTGRES_PASSWORD"

SLEEP_SECONDS=$1

echo "worker started with ${SLEEP_SECONDS}s interval"

while true; do
  today=$(date +%F)

  account_id=$(uuidgen)
  client_id=$(uuidgen)

  message='{"account_id": "'"$account_id"'", "client_id": "'"$client_id"'", "operation_type": "online"}'
  
  state=0

  created_operation_uuid=$(psql \
    -h "$POSTGRES_HOST" \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" \
    -v ON_ERROR_STOP=1 \
    -v today="$today" \
    -v op_id="$RANDOM" \
    -v state="$state" \
    -v msg="$message" \
    -t -A -q <<'SQL'
SELECT create_operation(
  :'today'::date,
  :'op_id'::numeric(12,2),
  :'state'::boolean,
  :'msg'::jsonb
);
SQL
  )
  
  echo "created operation: $created_operation_uuid"

  sleep "$SLEEP_SECONDS"
done

echo "worker shutdown"