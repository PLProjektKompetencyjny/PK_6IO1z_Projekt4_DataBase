/*
    Test query to create invocie for reservation number 1
    Expected result: success
*/

INSERT INTO invoice_view (invoice_reservation_id)
VALUES(1);