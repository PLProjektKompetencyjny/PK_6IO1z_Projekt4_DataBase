/*
    Test query to update user name for user account 
    Expected result: success
*/

UPDATE user_view
SET user_name = 'NewUserNameForUsrOne'
WHERE user_id = 1;