/*
    Test query to update invoice status in bulk for invoice 1 and 3
    Expected result: success
*/

UPDATE invoice_view
SET invoice_status_id = 3
WHERE invoice_id = 1 AND invoice_id = 3;