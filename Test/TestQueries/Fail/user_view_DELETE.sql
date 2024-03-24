/*
    Test query to delete user
    Expected result: fail
*/

DELETE FROM user_view
WHERE user_id = 1;