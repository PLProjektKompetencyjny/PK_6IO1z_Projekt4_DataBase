/*
    Test query to set user INACTIVE
    Expected result: success
*/

UPDATE user_view
SET user_is_active = FALSE
WHERE user_e_mail = 'myuser@wp.pl'