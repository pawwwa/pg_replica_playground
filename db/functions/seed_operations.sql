\connect privat_assignment

CREATE OR REPLACE PROCEDURE seed_operations(count INT)
LANGUAGE plpgsql
AS $$
DECLARE 
    i INT := 0;
    client_id uuid;
BEGIN
    client_id := uuid_generate_v4();
    WHILE i < count LOOP

        IF i % 150 = 0 THEN  -- minimum 150 ops for 1 user
            client_id := uuid_generate_v4();
        END IF;

        INSERT INTO operations(operation_date, operation_sum, state, operation_uuid, message)
        VALUES (
            (NOW() - (RANDOM() * INTERVAL '3 month'))::date,
            (RANDOM() * 999.00 + 1.00)::NUMERIC(12, 2),
            (RANDOM() < 0.5),
            uuid_generate_v4(),
            jsonb_build_object(
                'account_id', uuid_generate_v4(),
                'client_id', client_id,
                'operation_type', (
		            CASE
		                WHEN RANDOM() < 0.5 THEN 'offline' ELSE 'online'
		            END
        		)
            )
        );

        i := i + 1;
    END LOOP;
END;
$$;