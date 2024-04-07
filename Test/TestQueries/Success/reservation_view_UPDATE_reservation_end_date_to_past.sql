/*
    Test query to shorten reservation time period using end date
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_end_date = '2025-03-20'
WHERE reservation_id = 2;