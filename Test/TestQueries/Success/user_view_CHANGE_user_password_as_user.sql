/*
    Test query to change password as a user, old password provided is correct
    Expected result: success
*/


SELECT update_user_account_password('myuser@wp.pl', 'abc', 'mypass', NULL);

DO $$
BEGIN
    IF authenticate_user_account('myuser@wp.pl','abc') IS NULL THEN
        RAISE EXCEPTION 'Failed to authenticate with new password';
    END IF;
END $$;