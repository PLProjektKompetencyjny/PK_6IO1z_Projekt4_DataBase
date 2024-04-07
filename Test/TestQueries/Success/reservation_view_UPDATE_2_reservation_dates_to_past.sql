/*
    Test query to move reservation to another timeperiod in the past.
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_start_date = '2024-11-21',
	reservation_end_date = '2024-11-30'
WHERE reservation_id = 1;