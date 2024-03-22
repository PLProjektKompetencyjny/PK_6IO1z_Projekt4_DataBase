/*
    Test query to change password as a admin.
    Expected result: success
*/

SELECT update_user_account_password('myuser@wp.pl', 'adminPass','---',4);

DO $$
BEGIN
    IF authenticate_user_account('myuser@wp.pl','adminPass') IS NULL THEN
        RAISE EXCEPTION 'Failed to authenticate with new password';
    END IF;
END $$;