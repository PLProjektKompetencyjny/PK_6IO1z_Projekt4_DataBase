/*
    Test query to insert new user_account to the system
    Expected result: success
*/

SELECT insert_user_account('myuser@wp.pl','mypass', NULL);