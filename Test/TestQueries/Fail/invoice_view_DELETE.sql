/*
    Test query to delete invoice
    Expected result: fail
*/

DELETE FROM invoice_view
WHERE invoice_id = 1;