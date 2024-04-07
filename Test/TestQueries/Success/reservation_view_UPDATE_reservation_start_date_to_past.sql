/*
    Test query to extend reservation time period using start date
    Expected result: success
*/

UPDATE reservation_view 
SET 
	reservation_start_date = '2025-03-03'
WHERE reservation_id = 2;