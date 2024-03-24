/*
    Test query to delete customer details
    Expected result: fail
*/

DELETE FROM customer_view
WHERE customer_id = 1;