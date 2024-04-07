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

        Version:            1.3
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
*/

CREATE OR REPLACE FUNCTION update_reservation_view()
RETURNS TRIGGER AS $$
DECLARE
    Res_ID int;
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
	IF (NEW.reservation_number_of_adults IS DISTINCT FROM OLD.reservation_number_of_adults) THEN

		UPDATE reservation
		SET num_of_adults = NEW.reservation_number_of_adults
		WHERE id = Res_ID;

		RAISE NOTICE 
			'num_of_adults updated for reservation ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.reservation_number_of_adults, 
				NEW.reservation_number_of_adults;

		Any_ops_performed = TRUE;
	END IF;

	-- Check if reservation_number_of_children is changed
	IF (NEW.reservation_number_of_children IS DISTINCT FROM OLD.reservation_number_of_children) THEN

		UPDATE reservation
		SET num_of_children = NEW.reservation_number_of_children
		WHERE id = Res_ID;

		RAISE NOTICE 
			'num_of_childrem updated for reservation ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.reservation_number_of_children, 
				NEW.reservation_number_of_children;

		Any_ops_performed = TRUE;
	END IF;

	-- To omit raising an error by CONSTRAINT check, which is verifying if end_date > start_date,
	-- in case of changing both dates at the same time we have to perform it in appropriate order,
	-- which is handled in sub function
	IF (NEW.reservation_start_date IS DISTINCT FROM OLD.reservation_start_date) AND 
		(NEW.reservation_end_date IS DISTINCT FROM OLD.reservation_end_date) THEN
		
		UPDATE reservation
		SET 
			start_date = NEW.reservation_start_date,
			end_date = NEW.reservation_end_date
		WHERE id = Res_ID;

		RAISE NOTICE 
			'booking period updated for reservation ID: %. OLD: % - % NEW: % - %', 
				Res_ID, 
				OLD.reservation_start_date, 
				OLD.reservation_end_date, 
				NEW.reservation_start_date,
				NEW.reservation_end_date;

		Any_ops_performed = TRUE;
	ELSE
		-- Check if reservation_start_date is changed
		IF (NEW.reservation_start_date IS DISTINCT FROM OLD.reservation_start_date) THEN

			UPDATE reservation
			SET start_date = NEW.reservation_start_date
			WHERE id = Res_ID;

			RAISE NOTICE 
				'start_date updated for reservation ID: %. OLD: % NEW: %', 
					Res_ID, 
					OLD.reservation_start_date, 
					NEW.reservation_start_date;

			Any_ops_performed = TRUE;
		END IF;


		-- Check if reservation_end_date is changed
		IF (NEW.reservation_end_date IS DISTINCT FROM OLD.reservation_end_date) THEN

			UPDATE reservation
			SET end_date = NEW.reservation_end_date
			WHERE id = Res_ID;

			RAISE NOTICE 
				'end_date updated for reservation ID: %. OLD: % NEW: %', 
					Res_ID, 
					OLD.reservation_end_date, 
					NEW.reservation_end_date;

		Any_ops_performed = TRUE;
		END IF;
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


	-- Check if reservation_room_id is changed
	IF (NEW.reservation_room_id IS DISTINCT FROM OLD.reservation_room_id) THEN
		
		UPDATE reservation_room
		SET room_id = NEW.reservation_room_id
		WHERE reservation_id = Res_ID AND 
			room_id = OLD.reservation_room_id;

		RAISE NOTICE 
			'room_id updated for reservation ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.reservation_room_id, 
				NEW.reservation_room_id;

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

		RAISE NOTICE 
			'last_modified_by updated for reservation ID: %.', 
			Res_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE reservation
	SET last_modified_at = DEFAULT
	WHERE id = Res_ID;

	RAISE NOTICE 
		'last_modified_at updated for reservation ID: %.', 
			Res_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION update_invoice_view()
RETURNS TRIGGER AS $$
DECLARE
    Inv_ID int;
	Any_ops_performed boolean;
BEGIN

    Any_ops_performed := FALSE;

    -- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

	-- Assign invoice ID which will be modified to the local variable
    Inv_ID := NEW.invoice_id;


	-- Check if invoice status is changed
	IF (NEW.invoice_status_id IS DISTINCT FROM OLD.invoice_status_id) THEN

		UPDATE invoice
		SET status_id = NEW.invoice_status_id
		WHERE id = Inv_ID;

		RAISE NOTICE 
            'status_id updated for invoice ID: %. OLD: % NEW: %', 
                Inv_ID, 
                OLD.invoice_status_id, 
                NEW.invoice_status_id;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if invoice_price_gross is changed
	IF (NEW.invoice_price_gross IS DISTINCT FROM OLD.invoice_price_gross) THEN

		UPDATE invoice
		SET price_gross = NEW.invoice_price_gross
		WHERE id = Inv_ID;

		RAISE NOTICE 
			'price_gross updated for invoice ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.invoice_price_gross, 
				NEW.invoice_price_gross;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if invoice_is_paid is changed
	IF (NEW.invoice_is_paid IS DISTINCT FROM OLD.invoice_is_paid) THEN

		UPDATE reservation
		SET is_paid = NEW.invoice_is_paid
		WHERE id = Inv_ID;

		RAISE NOTICE 
			'is_paid updated for invoice ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.invoice_is_paid, 
				NEW.invoice_is_paid;

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
	IF (NEW.invoice_last_modified_by IS DISTINCT FROM OLD.invoice_last_modified_by) AND 
		NEW.invoice_last_modified_by IS NOT NULL THEN
		
		UPDATE invoice
		SET last_modified_by = NEW.invoice_last_modified_by
		WHERE id = Inv_ID;

		RAISE NOTICE 
			'last_modified_by updated for invoice ID: %.', 
			Inv_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE invoice
	SET last_modified_at = DEFAULT
	WHERE id = Inv_ID;

	RAISE NOTICE 
		'last_modified_at updated for invoice ID: %.', 
			Inv_ID;

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

		RAISE NOTICE 
            'status_id updated for room ID: %. OLD: % NEW: %', 
                Roo_ID, 
                OLD.room_status_id, 
                NEW.room_status_id;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if room type is changed
    IF (NEW.room_type_id IS DISTINCT FROM OLD.room_type_id) THEN

		UPDATE room
		SET room_type_id = NEW.room_type_id
		WHERE id = Roo_ID;

		RAISE NOTICE 
            'room_type_id updated for room ID: %. OLD: % NEW: %', 
                Roo_ID, 
                OLD.room_status_id, 
                NEW.room_status_id;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if room price is changed
    IF (NEW.room_gross_price IS DISTINCT FROM OLD.room_gross_price) THEN

		UPDATE room
		SET room_price_gross = NEW.room_gross_price
		WHERE id = Roo_ID;

		RAISE NOTICE 
            'room_type_id updated for room ID: %. OLD: % NEW: %', 
                Roo_ID, 
                OLD.room_status_id, 
                NEW.room_status_id;

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

		RAISE NOTICE 
			'last_modified_by updated for room ID: %.', 
			Roo_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE room
	SET last_modified_at = DEFAULT
	WHERE id = Roo_ID;

	RAISE NOTICE 
		'last_modified_at updated for room ID: %.', 
			Roo_ID;

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

		RAISE NOTICE 
            'user_name updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.user_name, 
                NEW.user_name;

		Any_ops_performed = TRUE;
	END IF;


	-- check if user e-mail is changed 
	IF (NEW.user_e_mail IS DISTINCT FROM OLD.user_e_mail) THEN

		UPDATE user_account
		SET e_mail = NEW.user_e_mail
		WHERE id = Usr_ID;

		RAISE NOTICE 
            'e_mail updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.user_e_mail, 
                NEW.user_e_mail;

		Any_ops_performed = TRUE;
	END IF;


	-- check if user active flag is changed 
	IF (NEW.user_is_active IS DISTINCT FROM OLD.user_is_active) THEN

		UPDATE user_account
		SET is_active = NEW.user_is_active
		WHERE id = Usr_ID;

		RAISE NOTICE 
            'is_active updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.user_is_active, 
                NEW.user_is_active;

		Any_ops_performed = TRUE;
	END IF;


	-- check if user admin flag is changed 
	IF (NEW.user_is_admin IS DISTINCT FROM OLD.user_is_admin) THEN

		IF NEW.user_is_admin = TRUE AND (OLD.user_name IS NOT NULL) THEN

			UPDATE user_account
			SET is_active = NEW.user_is_admin
			WHERE id = Usr_ID;

			RAISE NOTICE 
				'is_admin updated for account ID: %. OLD: % NEW: %', 
					Usr_ID, 
					OLD.user_is_admin, 
					NEW.user_is_admin;

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

		RAISE NOTICE 
			'last_modified_by updated for account ID: %.', 
			Usr_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE user_account
	SET last_modified_at = DEFAULT
	WHERE id = Usr_ID;

	RAISE NOTICE 
		'last_modified_at updated for account ID: %.', 
			Usr_ID;

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

		RAISE NOTICE 
            'nip_num updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.customer_nip_number, 
                NEW.customer_nip_number;

		Any_ops_performed = TRUE;
	END IF;


	-- check if customer name is changed
	IF (NEW.customer_name IS DISTINCT FROM OLD.customer_name) THEN

		UPDATE user_details
		SET name = NEW.customer_name
		WHERE user_id = Usr_ID;

		RAISE NOTICE 
            'name updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.customer_name, 
                NEW.customer_name;

		Any_ops_performed = TRUE;
	END IF;


	-- check if customer surname is changed
	IF (NEW.customer_surname IS DISTINCT FROM OLD.customer_surname) THEN

		UPDATE user_details
		SET surname = NEW.customer_surname
		WHERE user_id = Usr_ID;

		RAISE NOTICE 
            'surname updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.customer_surname, 
                NEW.customer_surname;

		Any_ops_performed = TRUE;
	END IF;


	-- check if customer phone number is changed
	IF (NEW.customer_phone IS DISTINCT FROM OLD.customer_phone) THEN

		UPDATE user_details
		SET phone_num = NEW.customer_phone
		WHERE user_id = Usr_ID;

		RAISE NOTICE 
            'phone_num updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.customer_phone, 
                NEW.customer_phone;

		Any_ops_performed = TRUE;
	END IF;


	-- check if city in customer address is changed
	IF (NEW.customer_city IS DISTINCT FROM OLD.customer_city) THEN

		UPDATE user_details
		SET city = NEW.customer_city
		WHERE user_id = Usr_ID;

		RAISE NOTICE 
            'city updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.customer_city, 
                NEW.customer_city;

		Any_ops_performed = TRUE;
	END IF;


	-- check if postal code in customer address is changed
	IF (NEW.customer_postal_code IS DISTINCT FROM OLD.customer_postal_code) THEN

		UPDATE user_details
		SET Postal_code = NEW.customer_postal_code
		WHERE user_id = Usr_ID;

		RAISE NOTICE 
            'city updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.customer_postal_code, 
                NEW.customer_postal_code;

		Any_ops_performed = TRUE;
	END IF;


	-- check if street name in customer address is changed
	IF (NEW.customer_street IS DISTINCT FROM OLD.customer_street) THEN

		UPDATE user_details
		SET Street = NEW.customer_street
		WHERE user_id = Usr_ID;

		RAISE NOTICE 
            'city updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.customer_street, 
                NEW.customer_street;

		Any_ops_performed = TRUE;
	END IF;


	-- check if building number in customer address is changed
	IF (NEW.customer_building_number IS DISTINCT FROM OLD.customer_building_number) THEN

		UPDATE user_details
		SET Building_Num = NEW.customer_building_number
		WHERE user_id = Usr_ID;

		RAISE NOTICE 
            'city updated for account ID: %. OLD: % NEW: %', 
                Usr_ID, 
                OLD.customer_building_number, 
                NEW.customer_building_number;

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

		RAISE NOTICE 
			'last_modified_by updated for account ID: %.', 
			Usr_ID;

	END IF;

	-- update last modify date (DEFAULT value is NOW())
	UPDATE user_details
	SET last_modified_at = DEFAULT
	WHERE user_id = Usr_ID;

	RAISE NOTICE 
		'last_modified_at updated for account ID: %.', 
			Usr_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;