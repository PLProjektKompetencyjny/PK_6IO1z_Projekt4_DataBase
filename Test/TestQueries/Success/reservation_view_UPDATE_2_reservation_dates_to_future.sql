/*
    Test query to move reservation to another timeperiod in the future.
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_start_date = '2028-03-21',
	reservation_end_date = '2028-04-22'
WHERE reservation_id = 1;
