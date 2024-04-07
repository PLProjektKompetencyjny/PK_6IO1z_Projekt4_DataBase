/*
    Test query to set both user_name and e_mail to NULL
    Expected result: fail
*/

UPDATE user_view
SET 
    user_e_mail = NULL,
    user_name = NULL
WHERE user_id = 1;