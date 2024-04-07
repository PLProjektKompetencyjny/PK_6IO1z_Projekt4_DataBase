/*
    Test query to update invoice status for invoice 2
    Expected result: success
*/

UPDATE invoice_view
SET invoice_status_id = 2
WHERE invoice_id = 2