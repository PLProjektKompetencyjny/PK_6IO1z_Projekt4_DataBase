/*
    Test query change room status along with filling in last modified by
    Expected result: success
*/

UPDATE room_view 
SET 
	room_status_id = 2,
    room_last_modified_by = 1
WHERE room_id = 5;