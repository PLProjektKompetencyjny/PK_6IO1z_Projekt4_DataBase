/*
    Test query to change reservation price for reservation 2
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_price_gross = 100
WHERE reservation_id = 2;
