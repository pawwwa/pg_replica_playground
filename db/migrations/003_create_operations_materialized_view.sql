\connect privat_assignment

CREATE MATERIALIZED VIEW IF NOT EXISTS operations_total_sum AS
SELECT 
    message->>'client_id'      AS client_id,
    message->>'operation_type' AS operation_type, 
    SUM(operation_sum)         AS total
FROM operations
WHERE state = 1::boolean
GROUP BY
    message->>'client_id',
	message->>'operation_type';

CREATE OR REPLACE FUNCTION trg_refresh_operations_total_sum()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM old_rows o
        JOIN new_rows n USING(id)
        WHERE o.state = 0::boolean
          AND n.state = 1::boolean
    ) THEN
        REFRESH MATERIALIZED VIEW operations_total_sum;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER refresh_operations_total_sum
AFTER UPDATE
ON operations
REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
FOR EACH STATEMENT
EXECUTE FUNCTION trg_refresh_operations_total_sum();