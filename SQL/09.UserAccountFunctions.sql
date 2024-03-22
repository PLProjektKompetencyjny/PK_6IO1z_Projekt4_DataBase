/*
    .DESCRIPTION
        SQL script for PostgreSQL to define functions for user_account management in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is suposed to define all functions, which will be used to:
            - Add new user account
            - Update user password
            - Delete user account

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Check function must have a prefix 'check_' in the name. 
            Beacause all functions are located in the common Object explorer directory

        - Check function must return True or False values only. Try to avoid raising any exceptions.
            In order to prevent handling any CHECK related exceptions in INSERT / UPDATE statements

        - Check function can be written in SQL or PL/Python, both languages are supported,
            however if a Python one requires some additional packages to import,
            it would require to update Dockerfile.


    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      22-Mar-2024
        ChangeLog:

        Date            Who                     What

*/

CREATE OR REPLACE FUNCTION insert_user_account(login varchar, user_password varchar, last_modified_by_id int)
RETURNS int AS $$
DECLARE
	New_User_ID int;
BEGIN
    -- check if provided login is an e-mail
    IF validate_e_mail(login) THEN

        -- create new account using e-mail field
	    INSERT INTO user_account (e_mail, password, last_modified_by)
	    VALUES (login, user_password, last_modified_by_id);

        -- get ID for newly created user
        SELECT
	    	ID
	    INTO New_User_ID
	    FROM user_account
	    WHERE e_mail = login;

    ELSE

        -- create new account using username field
    	INSERT INTO user_account (user_name, password, last_modified_by)
	    VALUES (login, user_password, last_modified_by_id);

        -- get ID for newly created user
        SELECT
	    	ID
	    INTO New_User_ID
	    FROM user_account
	    WHERE user_name = login;

    END IF;
	RETURN New_User_ID;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION update_user_account_password(login varchar, new_user_password varchar, old_user_password varchar, last_modified_by_id int)
RETURNS int AS $$
DECLARE
	User_ID_To_Return int;
    Is_Admin boolean;
BEGIN
    -- check if provided login is an e-mail
    IF validate_e_mail(login) THEN

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
        RAISE EXCEPTION 'User with login: % does not exist', login;
    END IF;

    -- get is_admin flag for last_modified_by_id user
    SELECT
        acc_tab.is_admin
    INTO Is_Admin
    FROM user_account acc_tab
    WHERE id = last_modified_by_id;

    IF (authenticate_user_account(login, old_user_password) = User_ID_To_Return) OR Is_Admin = TRUE THEN

        UPDATE user_account
        SET password = new_user_password
        WHERE id = User_ID_To_Return;

        RETURN User_ID_To_Return;
    
    ELSE
        RAISE EXCEPTION 'User old password is incorrect or requestor is not admin';

    END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION authenticate_user_account(login varchar, user_password varchar)
RETURNS int AS $$
DECLARE
	User_ID_To_Return int;
BEGIN
    -- check if login is an e-mail address
	IF validate_e_mail(login) THEN

        -- get an ID for user with provided e-mail
        SELECT 
            ID
        INTO User_ID_To_Return
        FROM User_account 
        WHERE e_mail = login;

    -- if login is not an e-mail 
    ELSE

        -- get an ID for user with provided username
        SELECT 
            ID
        INTO User_ID_To_Return
        FROM User_account 
        WHERE user_name = login;

    END IF;

    -- if provided username does not exist in DB raise exception
    IF User_ID_To_Return IS NULL THEN
        RAISE EXCEPTION 'User with login: % does not exist', login;
    END IF;

    -- check if provided password matches the one stored in DB
    -- if yes return authenticated user ID
    IF ((
        SELECT 
            password 
        FROM User_account
        WHERE id = User_ID_To_Return
        ) IS NOT DISTINCT FROM user_password) THEN

        RETURN User_ID_To_Return;
    END IF;
	
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

