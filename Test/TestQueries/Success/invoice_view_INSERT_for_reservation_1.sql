/*
    Test query to create invocie for reservation number 1
    Expected result: success
*/

INSERT INTO invoice_view (invoice_reservation_id, invoice_price_gross)
VALUES(1,100);