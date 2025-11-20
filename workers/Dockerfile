FROM alpine:3.20

RUN apk add --no-cache bash postgresql-client uuidgen

WORKDIR /workers

COPY worker_create_operation.sh /workers/
COPY worker_change_operation_state_by_time.sh /workers/
COPY worker_seeder.sh /workers/

RUN chmod +x /workers/worker_create_operation.sh
RUN chmod +x /workers/worker_change_operation_state_by_time.sh
RUN chmod +x /workers/worker_seeder.sh