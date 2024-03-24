/*
    Test query to authenticate user with incorrect
    Expected result: fail
*/

IF authenticate_user_account('myuser','Wmypass') IS NULL THEN
    RAISE EXCEPTION 'Failed to authenticate'
END IF;