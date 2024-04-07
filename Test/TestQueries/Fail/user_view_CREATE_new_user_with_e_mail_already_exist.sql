/*
    Test query to insert new user_account to the system,
    query will fail because user with this e-mail already exist
    Expected result: fail
*/

SELECT insert_user_account('myuser@wp.pl','mypasF', NULL);