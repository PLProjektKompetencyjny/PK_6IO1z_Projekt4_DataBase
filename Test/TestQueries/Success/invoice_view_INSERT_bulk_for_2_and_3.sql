/*
    Test query to create invoices for reservation number 2 and 3 in bulk
    Expected result: success
*/

INSERT INTO invoice_view (invoice_reservation_id)
VALUES
(2),
(3);