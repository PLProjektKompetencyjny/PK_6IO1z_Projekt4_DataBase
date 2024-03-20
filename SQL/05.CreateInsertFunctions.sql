/*
    .DESCRIPTION
        SQL script for PostgreSQL to define INSERT functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is suposed to define all insert functions,
        which will be used in INSTEAD OF INSERT view triggers.

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Insert function must have a prefix 'insert_' followed by <view_name> in the name. 
            Beacause all functions are located in the common Object explorer directory.

        - Insert function must return NULL if operation was successful, 
            otherwise raise an descriptive exception, which will be capture by backend.

        - Insert function can be written in SQL or PL/Python, both languages are supported,
            however RECOMMENDED FOR DATA MODIFICATION IS SQL.

        - Inser function must handle everything related to inserting record to DB,
            including all insert statements to any related table


    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      18-Mar-2024
        ChangeLog:

        Date            Who                     What

*/

CREATE OR REPLACE FUNCTION insert_reservation_view()
RETURNS TRIGGER AS $$
DECLARE
    R_ID int;
BEGIN
    -- Get reservation if this reservation already exists in DB,
    -- otherwise R_ID will be NULL
    SELECT
        subf_get_reservation_id(NEW)
    INTO R_ID;

    IF R_ID IS NULL THEN
        RAISE NOTICE 'Reservation not found';
        
        INSERT INTO Reservation (
            customer_id, 
            num_of_adults, 
            num_of_children, 
            start_date, 
            end_date, 
            price_gross,
            last_modified_by
            )
		VALUES (
            NEW.reservation_customer_id, 
            NEW.reservation_number_of_adults, 
            NEW.reservation_number_of_children, 
            NEW.reservation_start_date, 
            NEW.reservation_end_date, 
            NEW.reservation_price_gross,
            NEW.reservation_last_modified_by
            );

        -- Get reservation ID of newly inserted record
        SELECT
            subf_get_reservation_id(NEW)
        INTO R_ID;

        RAISE NOTICE 'New reservation inserted with ID: %', R_ID;
        -- Insert Room for reservation
        INSERT INTO Reservation_room (reservation_id, room_id)
        VALUES (R_ID, NEW.reservation_room_id);

		RETURN NEW;
    ELSE
        RAISE NOTICE 'Reservation found, ID: %', R_ID;
        
        -- Insert Room for reservation
        INSERT INTO Reservation_room (reservation_id, room_id)
        VALUES (R_ID, NEW.reservation_room_id);

        RAISE NOTICE 'Room % added to reservation with ID: %',NEW.reservation_room_id, R_ID;

        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION insert_invoice_view()
RETURNS TRIGGER AS $$
BEGIN

    INSERT INTO invoice (reservation_id, last_modified_by)
    VALUES (NEW.invoice_reservation_id, NEW.invoice_last_modified_by) 

	RETURN NEW;

END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION insert_room_view()
RETURNS TRIGGER AS $$
BEGIN

    INSERT INTO room (id, room_type_id, last_modified_by)
    VALUES (NEW.room_id, NEW.r) 

	RETURN NEW;

END;
$$ LANGUAGE plpgsql;