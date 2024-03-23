/*
    .DESCRIPTION
        SQL script for PostgreSQL to define INSERT functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is supposed to define all insert functions,
        which will be used in INSTEAD OF INSERT view triggers.

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Insert function must have a prefix 'insert_' followed by <view_name> in the name. 
            Because all functions are located in the common Object explorer directory.

        - Insert function must return NULL if operation was successful, 
            otherwise raise an descriptive exception, which will be capture by backend.

        - Insert function can be written in SQL or PL/Python, both languages are supported,
            however RECOMMENDED FOR DATA MODIFICATION IS SQL.

        - Insert function must handle everything related to inserting record to DB,
            including all insert statements to any related table


    .NOTES

        Version:            1.2
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      18-Mar-2024
        ChangeLog:

        Date            Who                     What
        2024-03-20      Stanisław Horna         added functions:
                                                    - insert_reservation_view
                                                    - insert_invoice_view
                                                    - insert_room_view
        
        2024-03-22      Stanisław Horna         added functions:
                                                    - insert_user_view
                                                    - insert_customer_view
                                                add SECURITY DEFINER <- to invoke functions with owner's permissions, 
                                                    instead of caller ones.

        2024-03-23		Stanisław Horna			Is_Paid and Price_gross moved from reservation to invoice table.
            
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

    -- if reservation with provided details does not exist insert a new one
    IF R_ID IS NULL THEN
        RAISE NOTICE 'Reservation not found';
        
        INSERT INTO Reservation (
            user_account_id, 
            num_of_adults, 
            num_of_children, 
            start_date, 
            end_date, 
            last_modified_by
            )
		VALUES (
            NEW.reservation_customer_id, 
            NEW.reservation_number_of_adults, 
            NEW.reservation_number_of_children, 
            NEW.reservation_start_date, 
            NEW.reservation_end_date, 
            NEW.reservation_last_modified_by
            );

        -- Get reservation ID of newly inserted record
        SELECT
            subf_get_reservation_id(NEW)
        INTO R_ID;

        RAISE NOTICE 'New reservation inserted with ID: %', R_ID;
        -- complete rooms for NEW reservation
        INSERT INTO Reservation_room (reservation_id, room_id)
        VALUES (R_ID, NEW.reservation_room_id);

		RETURN NEW;
    ELSE
        RAISE NOTICE 'Reservation found, ID: %', R_ID;
        
        -- complete rooms for existing reservation
        INSERT INTO Reservation_room (reservation_id, room_id)
        VALUES (R_ID, NEW.reservation_room_id);

        RAISE NOTICE 'Room % added to reservation with ID: %',NEW.reservation_room_id, R_ID;

        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION insert_invoice_view()
RETURNS TRIGGER AS $$
BEGIN

    -- just insert new invoice
    -- all conditions will be check by defined CONSTRAINTS
    INSERT INTO invoice (
        reservation_id, 
        last_modified_by,
        Price_gross
        )
    VALUES (
        NEW.invoice_reservation_id, 
        NEW.invoice_last_modified_by,
        NEW.invoice_price_gross
        );

	RETURN NEW;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION insert_room_view()
RETURNS TRIGGER AS $$
BEGIN

    -- just insert new room
    -- all conditions will be check by defined CONSTRAINTS
    INSERT INTO room (id, room_type_id, room_price_gross, last_modified_by)
    VALUES (NEW.room_id, NEW.room_type_id, NEW.room_gross_price, NEW.room_last_modified_by);

	RETURN NEW;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION insert_user_view()
RETURNS TRIGGER AS $$
BEGIN

    -- Raise exception as it is not allowed, because view does not contain passwords due to security reasons.
    -- the only way to create user and provide password is to use dedicated function
    RAISE EXCEPTION 'Operation not permitted, to insert user use insert_user_account() function.';

	RETURN NULL;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION insert_customer_view()
RETURNS TRIGGER AS $$
BEGIN

        -- just insert new room
        -- all conditions will be check by defined CONSTRAINTS
        INSERT INTO User_Details (
            user_id,
            nip_num, 
            name, 
            surname, 
            phone_num, 
            city, 
            postal_code,
            street,
            building_num,
            last_modified_by
            )
		VALUES (
            NEW.customer_id, 
            NEW.customer_nip_number, 
            NEW.customer_name, 
            NEW.customer_surname, 
            NEW.customer_phone, 
            NEW.customer_city,
            NEW.customer_postal_code,
            NEW.customer_street,
            NEW.customer_building_number,
            NEW.customer_last_modified_by
            );

	RETURN NEW;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;