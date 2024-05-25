/*
    Test query to change reserved room on reservation 1.
    Replace room 1 with room 2
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_room_id = 2
WHERE reservation_id = 1 AND reservation_room_id = 1;
