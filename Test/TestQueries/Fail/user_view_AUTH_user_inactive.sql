/*
    Test query to authenticate user with incorrect
    Expected result: fail
*/

IF authenticate_user_account('myuser@wp.pl','mypass') IS NULL THEN
    RAISE EXCEPTION 'Failed to authenticate';
END IF;