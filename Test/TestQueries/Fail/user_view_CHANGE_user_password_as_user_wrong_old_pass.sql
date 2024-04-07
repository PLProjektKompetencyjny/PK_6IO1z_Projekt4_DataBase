/*
    Test query to change password as a user.
    Query should fail because old password is incorrect
    Expected result: fail
*/

SELECT update_user_account_password('myuser@wp.pl', 'abc', 'Wmypass', NULL)