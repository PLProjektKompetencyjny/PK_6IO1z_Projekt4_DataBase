/*
    Test query to change password as a user, old password provided is correct
    Expected result: success
*/

SELECT update_user_account_password('myuser@wp.pl', 'abc', 'mypass', NULL)