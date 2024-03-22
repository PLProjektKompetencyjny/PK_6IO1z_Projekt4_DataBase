/*
    .DESCRIPTION
        SQL script for PostgreSQL to define UPDATE functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is suposed to define all update functions,
        which will be used in INSTEAD OF UPDATE view triggers.

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Update function must have a prefix 'update_' followed by <view_name> in the name. 
            Beacause all functions are located in the common Object explorer directory.

        - Update function must return NULL if operation was successful, 
            otherwise raise an descriptive exception, which will be capture by backend.

        - Update function can be written in SQL or PL/Python, both languages are supported,
            however RECOMMENDED FOR DATA MODIFICATION IS SQL.

        - Update function must handle everything related to updating record to DB,
            including checks which are required to identify if such action is allowed.


    .NOTES

        Version:            1.0
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

*/

CREATE OR REPLACE FUNCTION update_reservation_view()
RETURNS TRIGGER AS $$
DECLARE
    Res_ID int;
	Any_ops_performed bool;
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

	-- To ommit raising an error by CONSTRAINT check, which is verifying if end_date > start_date,
	-- in case of changing both dates at the same time we have to perform it in appropriate order,
	-- which is handdled in sub function
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


	-- Check if reservation_price_gross is changed
	IF (NEW.reservation_price_gross IS DISTINCT FROM OLD.reservation_price_gross) THEN

		UPDATE reservation
		SET price_gross = NEW.reservation_price_gross
		WHERE id = Res_ID;

		RAISE NOTICE 
			'price_gross updated for reservation ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.reservation_price_gross, 
				NEW.reservation_price_gross;

		Any_ops_performed = TRUE;
	END IF;


	-- Check if reservation_is_paid is changed
	IF (NEW.reservation_is_paid IS DISTINCT FROM OLD.reservation_is_paid) THEN

		UPDATE reservation
		SET is_paid = NEW.reservation_is_paid
		WHERE id = Res_ID;

		RAISE NOTICE 
			'is_paid updated for reservation ID: %. OLD: % NEW: %', 
				Res_ID, 
				OLD.reservation_is_paid, 
				NEW.reservation_is_paid;

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

	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;

	IF (NEW.reservation_last_modified_by IS DISTINCT FROM OLD.reservation_last_modified_by) AND 
		NEW.reservation_last_modified_by IS NOT NULL THEN
		
		UPDATE reservation
		SET last_modified_by = NEW.reservation_last_modified_by
		WHERE id = Res_ID;

		RAISE NOTICE 
			'last_modified_by updated for reservation ID: %.', 
			Res_ID;

	END IF;

	UPDATE reservation
	SET last_modified_at = DEFAULT
	WHERE id = Res_ID;

	RAISE NOTICE 
		'last_modified_at updated for reservation ID: %.', 
			Res_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION update_invoice_view()
RETURNS TRIGGER AS $$
DECLARE
    Inv_ID int;
	Any_ops_performed bool;
BEGIN

    Any_ops_performed := FALSE;

    -- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

    Inv_ID := NEW.invoice_id;

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

	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;

	IF (NEW.invoice_last_modified_by IS DISTINCT FROM OLD.invoice_last_modified_by) AND 
		NEW.invoice_last_modified_by IS NOT NULL THEN
		
		UPDATE invoice
		SET last_modified_by = NEW.invoice_last_modified_by
		WHERE id = Inv_ID;

		RAISE NOTICE 
			'last_modified_by updated for invoice ID: %.', 
			Inv_ID;

	END IF;

	UPDATE invoice
	SET last_modified_at = DEFAULT
	WHERE id = Inv_ID;

	RAISE NOTICE 
		'last_modified_at updated for invoice ID: %.', 
			Inv_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION update_room_view()
RETURNS TRIGGER AS $$
DECLARE
    Roo_ID int;
	Any_ops_performed bool;
BEGIN

    Any_ops_performed := FALSE;

    -- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

    Roo_ID := NEW.room_id;

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

	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;

	IF (NEW.room_last_modified_by IS DISTINCT FROM OLD.room_last_modified_by) AND 
		NEW.room_last_modified_by IS NOT NULL THEN
		
		UPDATE room
		SET last_modified_by = NEW.room_last_modified_by
		WHERE id = Roo_ID;

		RAISE NOTICE 
			'last_modified_by updated for room ID: %.', 
			Roo_ID;

	END IF;

	UPDATE room
	SET last_modified_at = DEFAULT
	WHERE id = Roo_ID;

	RAISE NOTICE 
		'last_modified_at updated for room ID: %.', 
			Roo_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION update_user_view()
RETURNS TRIGGER AS $$
DECLARE
    Usr_ID int;
	Any_ops_performed bool;
BEGIN

    Any_ops_performed := FALSE;

    -- Check if there is anything to update
	IF (NEW IS NOT DISTINCT FROM OLD) THEN
		RAISE NOTICE 'Seems like there is nothing to update';
	END IF;

    Usr_ID := NEW.user_id;


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


	IF (NEW.user_name IS DISTINCT FROM OLD.user_name) THEN

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


	IF Any_ops_performed = FALSE THEN

		RAISE EXCEPTION 
			'No update was performed';

		RETURN NULL;
	END IF;

	IF (NEW.user_last_modified_by IS DISTINCT FROM OLD.user_last_modified_by) AND 
		NEW.user_last_modified_by IS NOT NULL THEN
		
		UPDATE user_account
		SET last_modified_by = NEW.user_last_modified_by
		WHERE id = Usr_ID;

		RAISE NOTICE 
			'last_modified_by updated for account ID: %.', 
			Usr_ID;

	END IF;

	UPDATE user_account
	SET last_modified_at = DEFAULT
	WHERE id = Usr_ID;

	RAISE NOTICE 
		'last_modified_at updated for account ID: %.', 
			Usr_ID;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;