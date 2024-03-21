/*
    Test query to shorten reservation time period using start date
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_start_date = '2025-03-04'
WHERE reservation_id = 2;