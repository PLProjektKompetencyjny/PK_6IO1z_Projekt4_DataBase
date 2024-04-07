/*
    Test query to delete reservation
    Expected result: fail
*/

DELETE FROM reservation_view
WHERE reservation_id = 1;