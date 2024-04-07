/*
    Test query to update customer postal code - invalid code
    Expected result: fail
*/

UPDATE customer_view
SET customer_postal_code = '999-111'
WHERE customer_id = 1;