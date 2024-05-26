/*
    .DESCRIPTION
        SQL script for PostgreSQL to define UPDATE functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is supposed to define all update functions,
        which will be used in INSTEAD OF UPDATE view triggers.

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Update function must have a prefix 'update_' followed by <view_name> in the name. 
            Because all functions are located in the common Object explorer directory.

        - Update function must return NULL if operation was successful, 
            otherwise raise an descriptive exception, which will be capture by backend.

        - Update function can be written in SQL or PL/Python, both languages are supported,
            however RECOMMENDED FOR DATA MODIFICATION IS SQL.

        - Update function must handle everything related to updating record to DB,
            including checks which are required to identify if such action is allowed.


    .NOTES

        Version:            1.7
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      18-Mar-2024
        ChangeLog:

        Date            Who                     What
        2024-03-20      Stanisław Horna         added functions:
                                                    - update_reservation_view
                                                    - update_invoice_view
                                                    - update_room_view

		2024-03-22		Stanisław Horna			added functions:
													- update_user_view
													- update_customer_view

        2024-03-22      Stanisław Horna         add SECURITY DEFINER <- to invoke functions with owner's permissions, 
                                                    instead of caller ones.

		2024-03-23		Stanisław Horna			Is_Paid and Price_gross moved from reservation to invoice table.
												Additional validation for update_user_view() added.

		2024-04-30		Stanisław Horna			add update_service_view function.

        2024-05-25      Stanisław Horna         add verification if number of people assigned to the room
                                                is not grater then number of beds.
												Remove option to update following fields in reservation_view:
													- start_date
													- end_date
													- room_id

        2024-05-26      Stanisław Horna         add invoice recalculation after reservation changes.
*/

CREATE OR REPLACE FUNCTION update_reservation_view()
RETURNS TRIGGER AS $$
DECLARE
    Res_ID int;
    Roo_ID int;
	Any_ops_performed boolean;
BEGIN

	Any_ops_performed := FALSE;

	-- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

	-- Assign reservation ID which will be modified to the local variable
	Res_ID := OLD.reservation_ID;


	-- Check if reservation_number_of_adults is changed
	IF (NEW.room_number_of_adults IS DISTINCT FROM OLD.room_number_of_adults)
		AND (OLD.reservation_room_id IS NOT NULL) THEN

		UPDATE reservation_room
		SET num_of_adults = NEW.room_number_of_adults
		WHERE reservation_id = Res_ID
			AND room_id = OLD.reservation_room_id;

		PERFORM check_room_guest_number(OLD.reservation_room_id, Res_ID);

		PERFORM calculate_reservation_room_price(OLD.reservation_room_id, Res_ID);

		PERFORM calculate_invoice_price(Res_ID);

		RAISE NOTICE 
			'num_of_adults updated for reservation ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.room_number_of_adults, 
				NEW.room_number_of_adults;

		Any_ops_performed = TRUE;
	END IF;

	-- Check if reservation_number_of_children is changed
	IF (NEW.room_number_of_children IS DISTINCT FROM OLD.room_number_of_children) 
		AND (OLD.reservation_room_id IS NOT NULL) THEN

		UPDATE reservation_room
		SET num_of_children = NEW.room_number_of_children
		WHERE reservation_id = Res_ID
			AND room_id = OLD.reservation_room_id;

		PERFORM check_room_guest_number(OLD.reservation_room_id, Res_ID);

		PERFORM calculate_reservation_room_price(OLD.reservation_room_id, Res_ID);
		
		PERFORM calculate_invoice_price(Res_ID);

		RAISE NOTICE 
			'num_of_children updated for reservation ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.room_number_of_children, 
				NEW.room_number_of_children;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if reservation_status_id is changed
	IF (NEW.reservation_status_id IS DISTINCT FROM OLD.reservation_status_id) THEN

		UPDATE reservation
		SET status_id = NEW.reservation_status_id
		WHERE id = Res_ID;

		RAISE NOTICE 
			'status_id updated for reservation ID: %. OLD: % NEW: %', 
			Res_ID, 
			OLD.reservation_status_id, 
			NEW.reservation_status_id;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if reservation_room_status_id is changed
	IF (NEW.reservation_room_status_id IS DISTINCT FROM OLD.reservation_room_status_id) THEN
		
		UPDATE reservation_room
		SET room_status_id = NEW.reservation_room_status_id
		WHERE reservation_id = Res_ID AND 
			room_id = OLD.reservation_room_id;

		RAISE NOTICE 
			'reservation_room_status_id updated for reservation ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.reservation_room_status_id, 
				NEW.reservation_room_status_id;

		Any_ops_performed = TRUE;
	END IF;


	-- check if any operation was performed,
	-- if not raise an exception to notify that wanted operation was not performed
	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;


	-- check if last modifier changed and is not null
	IF (NEW.reservation_last_modified_by IS DISTINCT FROM OLD.reservation_last_modified_by) AND 
		NEW.reservation_last_modified_by IS NOT NULL THEN
		
		UPDATE reservation
		SET last_modified_by = NEW.reservation_last_modified_by
		WHERE id = Res_ID;


	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE reservation
	SET last_modified_at = DEFAULT
	WHERE id = Res_ID;


	RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION update_invoice_view()
RETURNS TRIGGER AS $$
DECLARE
    Inv_ID int;
	R_ID int;
BEGIN

	-- Assign invoice ID which will be modified to the local variable
    Inv_ID := NEW.invoice_id;

	SELECT
		RESERVATION_ID INTO R_ID
	FROM
		INVOICE
	WHERE
		ID = INV_ID;

	-- Check if invoice status is changed
	IF (NEW.invoice_status_id IS DISTINCT FROM OLD.invoice_status_id) THEN

		UPDATE invoice
		SET status_id = NEW.invoice_status_id
		WHERE id = Inv_ID;

	END IF;


	IF (NEW.invoice_date IS DISTINCT FROM OLD.invoice_date) THEN

		RAISE EXCEPTION 'Modification of invoice date is not allowed';
		RETURN NEW;

	END IF;

	-- Check if invoice status is changed
	IF (NEW.invoice_status_id IS DISTINCT FROM OLD.invoice_status_id) THEN

		UPDATE invoice
		SET status_id = NEW.invoice_status_id
		WHERE id = Inv_ID;

	END IF;

	-- Check if invoice_is_paid is changed
	IF (NEW.invoice_is_paid IS DISTINCT FROM OLD.invoice_is_paid) THEN

		UPDATE reservation
		SET is_paid = NEW.invoice_is_paid
		WHERE id = Inv_ID;

	END IF;

	-- check if last modifier changed and is not null
	IF (NEW.invoice_last_modified_by IS DISTINCT FROM OLD.invoice_last_modified_by) AND 
		NEW.invoice_last_modified_by IS NOT NULL THEN
		
		UPDATE invoice
		SET last_modified_by = NEW.invoice_last_modified_by
		WHERE id = Inv_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE invoice
	SET last_modified_at = DEFAULT
	WHERE id = Inv_ID;

	PERFORM calculate_invoice_price(R_ID);

	RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION update_room_view()
RETURNS TRIGGER AS $$
DECLARE
    Roo_ID int;
	Any_ops_performed boolean;
BEGIN

    Any_ops_performed := FALSE;

    -- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

	-- Assign room ID which will be modified to the local variable
    Roo_ID := NEW.room_id;


	-- Check if room status is changed
	IF (NEW.room_status_id IS DISTINCT FROM OLD.room_status_id) THEN

		UPDATE room
		SET status_id = NEW.room_status_id
		WHERE id = Roo_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if room type is changed
    IF (NEW.room_type_id IS DISTINCT FROM OLD.room_type_id) THEN

		UPDATE room
		SET room_type_id = NEW.room_type_id
		WHERE id = Roo_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if room price is changed
    IF (NEW.room_gross_price IS DISTINCT FROM OLD.room_gross_price) THEN

		UPDATE room
		SET room_price_gross = NEW.room_gross_price
		WHERE id = Roo_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if any operation was performed,
	-- if not raise an exception to notify that wanted operation was not performed
	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;


	-- check if last modifier changed and is not null
	IF (NEW.room_last_modified_by IS DISTINCT FROM OLD.room_last_modified_by) AND 
		NEW.room_last_modified_by IS NOT NULL THEN
		
		UPDATE room
		SET last_modified_by = NEW.room_last_modified_by
		WHERE id = Roo_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE room
	SET last_modified_at = DEFAULT
	WHERE id = Roo_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION update_user_view()
RETURNS TRIGGER AS $$
DECLARE
    Usr_ID int;
	Any_ops_performed boolean;
BEGIN

    Any_ops_performed := FALSE;

    -- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

	-- Assign user ID which will be modified to the local variable
    Usr_ID := NEW.user_id;


	-- check if username is changed 
	IF (NEW.user_name IS DISTINCT FROM OLD.user_name) THEN

		IF check_validate_e_mail(NEW.user_name) THEN
			RAISE EXCEPTION 
				'Value % can not be set as user_name, because it is an e-mail',
				NEW.user_name;
			RETURN NULL;
		END IF;

		UPDATE user_account
		SET user_name = NEW.user_name
		WHERE id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if user e-mail is changed 
	IF (NEW.user_e_mail IS DISTINCT FROM OLD.user_e_mail) THEN

		UPDATE user_account
		SET e_mail = NEW.user_e_mail
		WHERE id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if user active flag is changed 
	IF (NEW.user_is_active IS DISTINCT FROM OLD.user_is_active) THEN

		UPDATE user_account
		SET is_active = NEW.user_is_active
		WHERE id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if user admin flag is changed 
	IF (NEW.user_is_admin IS DISTINCT FROM OLD.user_is_admin) THEN

		IF NEW.user_is_admin = TRUE AND (OLD.user_name IS NOT NULL) THEN

			UPDATE user_account
			SET is_active = NEW.user_is_admin
			WHERE id = Usr_ID;

		ELSE

			RAISE EXCEPTION 
				'account without user_name can not be promoted to admin';
			RETURN NULL;
		END IF;

		Any_ops_performed = TRUE;
	END IF;


	-- check if any operation was performed,
	-- if not raise an exception to notify that wanted operation was not performed
	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;


	-- check if last modifier changed and is not null
	IF (NEW.user_last_modified_by IS DISTINCT FROM OLD.user_last_modified_by) AND 
		NEW.user_last_modified_by IS NOT NULL THEN
		
		UPDATE user_account
		SET last_modified_by = NEW.user_last_modified_by
		WHERE id = Usr_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE user_account
	SET last_modified_at = DEFAULT
	WHERE id = Usr_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION update_customer_view()
RETURNS TRIGGER AS $$
DECLARE
    Usr_ID int;
	Any_ops_performed boolean;
BEGIN

    Any_ops_performed := FALSE;

    -- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

	-- Assign user ID which will be modified to the local variable
    Usr_ID := NEW.Customer_id;


	-- check if customer nip number is changed
	IF (NEW.customer_nip_number IS DISTINCT FROM OLD.customer_nip_number) THEN

		UPDATE user_details
		SET nip_num = NEW.customer_nip_number
		WHERE user_id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if customer name is changed
	IF (NEW.customer_name IS DISTINCT FROM OLD.customer_name) THEN

		UPDATE user_details
		SET name = NEW.customer_name
		WHERE user_id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if customer surname is changed
	IF (NEW.customer_surname IS DISTINCT FROM OLD.customer_surname) THEN

		UPDATE user_details
		SET surname = NEW.customer_surname
		WHERE user_id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if customer phone number is changed
	IF (NEW.customer_phone IS DISTINCT FROM OLD.customer_phone) THEN

		UPDATE user_details
		SET phone_num = NEW.customer_phone
		WHERE user_id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if city in customer address is changed
	IF (NEW.customer_city IS DISTINCT FROM OLD.customer_city) THEN

		UPDATE user_details
		SET city = NEW.customer_city
		WHERE user_id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if postal code in customer address is changed
	IF (NEW.customer_postal_code IS DISTINCT FROM OLD.customer_postal_code) THEN

		UPDATE user_details
		SET Postal_code = NEW.customer_postal_code
		WHERE user_id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if street name in customer address is changed
	IF (NEW.customer_street IS DISTINCT FROM OLD.customer_street) THEN

		UPDATE user_details
		SET Street = NEW.customer_street
		WHERE user_id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if building number in customer address is changed
	IF (NEW.customer_building_number IS DISTINCT FROM OLD.customer_building_number) THEN

		UPDATE user_details
		SET Building_Num = NEW.customer_building_number
		WHERE user_id = Usr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- check if any operation was performed,
	-- if not raise an exception to notify that wanted operation was not performed
	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;


	-- check if last modifier changed and is not null
	IF (NEW.customer_last_modified_by IS DISTINCT FROM OLD.customer_last_modified_by) AND 
		NEW.customer_last_modified_by IS NOT NULL THEN
		
		UPDATE user_details
		SET last_modified_by = NEW.customer_last_modified_by
		WHERE user_id = Usr_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE user_details
	SET last_modified_at = DEFAULT
	WHERE user_id = Usr_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE OR REPLACE FUNCTION update_service_view()
RETURNS TRIGGER AS $$
DECLARE
    svr_ID int;
	Any_ops_performed boolean;
BEGIN

    Any_ops_performed := FALSE;

    -- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

	-- Assign service ID which will be modified to the local variable
    svr_ID := NEW.service_ID;


	-- Check if service name is changed
	IF (NEW.service_name IS DISTINCT FROM OLD.service_name) THEN

		UPDATE service
		SET name = NEW.service_name
		WHERE id = svr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if service price is changed
	IF (NEW.service_price IS DISTINCT FROM OLD.service_price) THEN

		UPDATE service
		SET unit_price = NEW.service_price
		WHERE id = svr_ID;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if service price is changed
	IF (NEW.service_quantity IS DISTINCT FROM OLD.service_quantity) AND 
		NEW.service_reservation_id IS NOT NULL THEN

		UPDATE reservation_service
		SET quantity = NEW.service_quantity
		WHERE id = svr_ID AND reservation_id = NEW.service_reservation_id;

		Any_ops_performed = TRUE;
	END IF;


	-- check if any operation was performed,
	-- if not raise an exception to notify that wanted operation was not performed
	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;


	-- check if last modifier changed and is not null
	IF (NEW.service_last_modified_by IS DISTINCT FROM OLD.service_last_modified_by) AND 
		NEW.service_last_modified_by IS NOT NULL THEN
		
		UPDATE service
		SET last_modified_by = NEW.service_last_modified_by
		WHERE id = svr_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE service
	SET last_modified_at = DEFAULT
	WHERE id = svr_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;