/*
    Test query to promote user account with user_name to admin 
    Expected result: success
*/

UPDATE user_view
SET user_is_admin = TRUE
WHERE user_id = 2;