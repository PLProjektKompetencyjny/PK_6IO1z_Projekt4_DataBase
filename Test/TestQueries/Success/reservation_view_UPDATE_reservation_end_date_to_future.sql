/*
    Test query to extend reservation time period using end date
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_end_date = '2025-03-25'
WHERE reservation_id = 2;