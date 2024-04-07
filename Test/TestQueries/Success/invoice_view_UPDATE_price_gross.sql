/*
    Test query to change invoice price gross for reservation 2
    Expected result: success
*/


UPDATE invoice_view 
SET 
	invoice_price_gross = 100
WHERE invoice_reservation_id = 2;
