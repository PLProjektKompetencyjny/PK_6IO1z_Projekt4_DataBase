/*
    Test query to insert new user_account to the system
    Expected result: success
*/

SELECT insert_user_account('myuser','mypass', NULL);

DO $$
BEGIN

    IF (
            SELECT 
            user_name 
            FROM user_account 
            WHERE id = authenticate_user_account('myuser','mypass')
        ) <> 'myuser' THEN
        
            RAISE EXCEPTION 'Failed to authenticate with new password';
    END IF;
END $$;