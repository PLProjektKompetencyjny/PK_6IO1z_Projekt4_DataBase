/*
    Test query to delete room
    Expected result: fail
*/

DELETE FROM room_view
WHERE room_id = 1;