/*
    Test query to change invoice date, which is not allowed
    Expected result: fail
*/

UPDATE invoice_view
SET invoice_date = '2029-01-01'
WHERE invoice_id = 1