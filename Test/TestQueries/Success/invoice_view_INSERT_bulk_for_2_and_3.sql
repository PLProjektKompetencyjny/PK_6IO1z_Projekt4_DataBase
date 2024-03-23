/*
    Test query to create invoices for reservation number 2 and 3 in bulk
    Expected result: success
*/

INSERT INTO invoice_view (invoice_reservation_id, invoice_price_gross)
VALUES
(2,200),
(3,300);