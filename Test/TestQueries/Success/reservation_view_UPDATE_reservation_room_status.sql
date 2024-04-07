/*
    Test query to change reservation room status for room 1 on reservation 2
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_room_id = 3
WHERE reservation_id = 2 AND reservation_room_id = 1;