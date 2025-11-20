\connect privat_assignment

CREATE OR REPLACE FUNCTION change_operation_state_by_time(
    _timestamp TIMESTAMP
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE operations
    SET state = 1::boolean
    WHERE state = 0::boolean 
      AND id % 2 = (EXTRACT(EPOCH FROM _timestamp)::INT % 2);
END;
$$;