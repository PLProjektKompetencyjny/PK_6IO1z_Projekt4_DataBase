/*
    .DESCRIPTION
        SQL script for PostgreSQL to define functions for user_account management in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is supposed to define all functions, which will be used to:
            - Add new user account
            - Update user password

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Function can be written in SQL or PL/Python, both languages are supported,
            however RECOMMENDED FOR DATA MODIFICATION IS SQL.


    .NOTES

        Version:            1.4
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      22-Mar-2024
        ChangeLog:

        Date            Who                     What
        2024-03-22      Stanisław Horna         handling for last_modified_by, inactive user can not authenticate.

        2024-03-23      Stanisław Horna         add SECURITY DEFINER <- to invoke functions with owner's permissions.

        2024-05-26      Stanisław Horna         use hash functions for passwords

        2024-05-28      Stanisław Horna         add custom SQLSTATE to exceptions.
*/

CREATE OR REPLACE FUNCTION insert_user_account(login varchar, user_password varchar, last_modified_by_id int)
RETURNS int AS $$
DECLARE
	New_User_ID int;
BEGIN
    -- check if provided login is an e-mail
    IF check_validate_e_mail(login) THEN

        -- create new account using e-mail field
	    INSERT INTO user_account (e_mail, password)
	    VALUES (login, get_hash(user_password));

        -- get ID for newly created user
        SELECT
	    	ID
	    INTO New_User_ID
	    FROM user_account
	    WHERE e_mail = login;

    ELSE

        -- create new account using username field
    	INSERT INTO user_account (user_name, password)
	    VALUES (login, get_hash(user_password));

        -- get ID for newly created user
        SELECT
	    	ID
	    INTO New_User_ID
	    FROM user_account
	    WHERE user_name = login;

    END IF;


    -- if last modified by is not passed to the function assume that this registration was made by the user itself
    IF last_modified_by_id IS NULL THEN

        UPDATE user_account
        SET last_modified_by = New_User_ID
        WHERE id = New_User_ID;
    
    ELSE -- if last modified by was passed set it for this new user account

        UPDATE user_account
        SET last_modified_by = last_modified_by_id
        WHERE id = New_User_ID;

    END IF;

	RETURN New_User_ID;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION update_user_account_password(login varchar, new_user_password varchar, old_user_password varchar, last_modified_by_id int)
RETURNS int AS $$
DECLARE
	User_ID_To_Return int;
    Is_Admin boolean;
BEGIN
    -- check if provided login is an e-mail
    IF check_validate_e_mail(login) THEN

        -- get ID for newly created user
        SELECT
            ID
        INTO User_ID_To_Return
        FROM user_account
        WHERE e_mail = login;

    ELSE

        -- get ID for newly created user
        SELECT
            ID
        INTO User_ID_To_Return
        FROM user_account
        WHERE user_name = login;

    END IF;

    -- if provided username does not exist in DB raise exception
    IF User_ID_To_Return IS NULL THEN
        RAISE EXCEPTION 'Cannot change user password'
                USING ERRCODE = '23520',
                TABLE = 'user';
        RETURN NULL;
    END IF;

    -- get is_admin flag for last_modified_by_id user
    SELECT
        acc_tab.is_admin
    INTO Is_Admin
    FROM user_account acc_tab
    WHERE id = last_modified_by_id;

    -- update password if last_modified_by_id is admin user
    IF Is_Admin IS TRUE THEN

        -- change password
        UPDATE user_account
        SET password = get_hash(new_user_password),
            last_modified_by = last_modified_by_id
        WHERE id = User_ID_To_Return;

        RETURN User_ID_To_Return;
    END IF;

    -- check if user can be authenticated or if requestor is admin
    IF (authenticate_user_account(login, old_user_password) = User_ID_To_Return) THEN

        -- change password
        UPDATE user_account
        SET password = get_hash(new_user_password),
            last_modified_by = User_ID_To_Return
        WHERE id = User_ID_To_Return;

        -- return ID of the user which account was modified
        RETURN User_ID_To_Return;
    
    ELSE
        RAISE EXCEPTION 'Cannot change user password'
                USING ERRCODE = '23520',
                TABLE = 'user';
    END IF;


	RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION authenticate_user_account(login varchar, user_password varchar)
RETURNS int AS $$
DECLARE
	User_ID_To_Return int;
    User_Is_Active boolean;
BEGIN
    -- check if login is an e-mail address
    -- based on it decide if authentication will be performed via e-mail or username
	IF check_validate_e_mail(login) THEN

        -- get an ID for user with provided e-mail
        SELECT 
            ID
        INTO User_ID_To_Return
        FROM User_account 
        WHERE e_mail = login;

    ELSE  -- if login is not an e-mail 

        -- get an ID for user with provided username
        SELECT 
            ID
        INTO User_ID_To_Return
        FROM User_account 
        WHERE user_name = login;

    END IF;

    -- if provided username does not exist in DB raise exception
    IF User_ID_To_Return IS NULL THEN
        RAISE EXCEPTION 'Cannot authenticate user'
                USING ERRCODE = '23521',
                TABLE = 'user';
    END IF;

    -- get user is active status
    SELECT 
        is_active
    INTO User_Is_Active
    FROM User_account 
    WHERE ID = User_ID_To_Return;


    -- if user account is not active it can not be authenticated successfully 
    IF User_Is_Active <> TRUE THEN
        RAISE EXCEPTION 'User is inactive'
                USING ERRCODE = '23519',
                TABLE = 'user';
        RETURN NULL;
    END IF;

    -- check if provided password matches the one stored in DB
    -- if yes return authenticated user ID
    IF (
        SELECT
            compare_hashes(user_password, (        
                SELECT 
                    "password"
                FROM User_account
                WHERE id = User_ID_To_Return
                )
            )
    ) THEN

        RETURN User_ID_To_Return;
    END IF;
	
    -- if password was not correct raise a notice and do not return user ID
	RAISE EXCEPTION 'Cannot authenticate user'
			USING ERRCODE = '23521',
			TABLE = 'user';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

