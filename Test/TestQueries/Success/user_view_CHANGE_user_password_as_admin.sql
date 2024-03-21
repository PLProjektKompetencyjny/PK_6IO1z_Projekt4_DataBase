/*
    Test query to change password as a admin.
    Expected result: success
*/

SELECT update_user_account_password('myuser@wp.pl', 'adminPass','---',4)