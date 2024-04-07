/*
    Test query to update customer phone - invalid format
    Expected result: fail
*/

UPDATE customer_view
SET customer_phone = '123456789'
WHERE customer_id = 1;
