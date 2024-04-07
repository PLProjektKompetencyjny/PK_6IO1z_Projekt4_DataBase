/*
    Test query change room price for room id 40
    Expected result: success
*/

UPDATE room_view 
SET 
	room_gross_price = 20000
WHERE room_id = 40;