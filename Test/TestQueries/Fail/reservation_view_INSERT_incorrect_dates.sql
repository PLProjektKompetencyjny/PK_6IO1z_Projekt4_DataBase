/*
    Test query to insert reservation with incorrect dates.
    start date > end date
    Expected result: fail
*/

INSERT INTO reservation_view (reservation_customer_id, reservation_number_of_adults, reservation_number_of_children, reservation_price_gross, reservation_start_date, reservation_end_date, reservation_room_id)
VALUES
    (1,1,1,1,'2030-03-01','2030-02-21',1);