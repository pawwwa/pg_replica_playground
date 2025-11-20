\connect privat_assignment

CREATE TABLE IF NOT EXISTS operations (
    id              bigserial       NOT NULL,
    operation_date  date            NOT NULL,
    operation_sum   NUMERIC(12, 2)  NOT NULL,
    state           boolean         NOT NULL,
    operation_uuid  uuid            NOT NULL,
    message         jsonb           NOT NULL,
    PRIMARY KEY (operation_date, id),
    UNIQUE (operation_date, operation_uuid)
) PARTITION BY RANGE (operation_date);