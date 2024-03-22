/*
    Test query to change number of beds for room 1
    Expected result: fail
*/

UPDATE room_view
SET 
    room_number_of_single_beds = 2,
    room_number_of_double_beds = 0,
    room_number_of_child_beds = 2
WHERE room_id = 1;