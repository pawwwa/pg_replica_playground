\connect privat_assignment

CREATE OR REPLACE FUNCTION create_operation(
    _operation_date date,
    _operation_sum  NUMERIC(12, 2),
    _state          boolean,
    _message        jsonb
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    operation_uuid uuid;
BEGIN
    operation_uuid := uuid_generate_v4();

    INSERT INTO operations (
        operation_date, operation_sum, state, operation_uuid, message
    )
    VALUES (
        _operation_date, _operation_sum, _state, operation_uuid, _message
    );

    RETURN operation_uuid;
END;
$$;