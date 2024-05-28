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


        Version:            1.8
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

        2024-04-06      Stanisław Horna         Price gross calculation added to invoice insert function.
		
		2024-04-30		Stanisław Horna			add insert_service_view function.

        2024-05-24      Stanisław Horna         add verification if room is available, before inserting reservation.
                                                Duplicated code simplified in insert_reservation_view().

        2024-05-25      Stanisław Horna         add verification if number of people assigned to the room
                                                is not grater then number of beds.

        2024-05-26      Stanisław Horna         add invoice recalculation after reservation changes.
                                                add invoice recalculation if there is invoice for provided reservation

*/

CREATE OR REPLACE FUNCTION insert_reservation_view()
RETURNS TRIGGER AS $$
DECLARE
    R_ID int;
BEGIN
    -- Get reservation if this reservation already exists in DB,
    -- otherwise R_ID will be NULL
    SELECT
        get_reservation_id(NEW)
    INTO R_ID;

    -- check if room can be booked
    PERFORM check_room_availability(NEW.reservation_room_id, NEW.reservation_start_date, NEW.reservation_end_date);

    -- if reservation with provided details does not exist insert a new one
    IF R_ID IS NULL THEN
        
        INSERT INTO Reservation (
            user_account_id, 
            start_date, 
            end_date, 
            last_modified_by
            )
		VALUES (
            NEW.reservation_customer_id, 
            NEW.reservation_start_date, 
            NEW.reservation_end_date, 
            NEW.reservation_last_modified_by
            )
        RETURNING ID INTO R_ID;

    END IF;

    -- Add rooms for reservation with more than 1 room
    INSERT INTO Reservation_room (
        reservation_id, 
        room_id,
        Num_of_adults, 
        Num_of_children 
        )
    VALUES (
        R_ID, 
        NEW.reservation_room_id,
        NEW.room_number_of_adults, 
        NEW.room_number_of_children
        );

    PERFORM check_room_guest_number(NEW.reservation_room_id, R_ID);

    PERFORM calculate_reservation_room_price(NEW.reservation_room_id, R_ID);

    PERFORM calculate_invoice_price(R_ID);

	RETURN NEW;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION insert_invoice_view()
RETURNS TRIGGER AS $$
DECLARE
    Res_ID int;
	Price_gross float;
BEGIN

    -- assign reservation_id to local variable 
    Res_ID := NEW.invoice_reservation_id;

    IF NOT EXISTS (
        SELECT
            ID
        FROM
            INVOICE
        WHERE
            reservation_id = Res_ID
    ) THEN

        -- just insert new invoice
        -- all conditions will be check by defined CONSTRAINTS
        INSERT INTO invoice (
            reservation_id, 
            last_modified_by
            )
        VALUES (
            Res_ID, 
            NEW.invoice_last_modified_by
            );

    END IF;

    PERFORM calculate_invoice_price(Res_ID);

	RETURN NEW;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE OR REPLACE FUNCTION insert_user_view()
RETURNS TRIGGER AS $$
BEGIN

    -- Raise exception as it is not allowed, because view does not contain passwords due to security reasons.
    -- the only way to create user and provide password is to use dedicated function
    RAISE EXCEPTION 'Operation not permitted.';

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

CREATE OR REPLACE FUNCTION insert_service_view()
RETURNS TRIGGER AS $$
BEGIN

    IF NEW.service_name IS NOT NULL THEN

        RAISE EXCEPTION 'Inserting new services is not allowed in this view';
        RETURN NEW;

    ELSE
        INSERT INTO reservation_service (
            reservation_id,
            service_id,
            quantity
        )
        VALUES (
            NEW.service_reservation_id,
            NEW.service_id,
            NEW.service_quantity
        );

    END IF;

    PERFORM calculate_invoice_price(NEW.service_reservation_id);

	RETURN NEW;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;