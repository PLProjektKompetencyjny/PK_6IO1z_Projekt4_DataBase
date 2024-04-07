/*
    Test query to promote user account without user_name to admin
    Expected result: fail
*/

UPDATE user_view
SET user_is_admin = TRUE
WHERE user_id = 5;