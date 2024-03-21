/*
    Test query to insert reservation with 1 Room for room id 1
    Expected result: success
*/
INSERT INTO reservation_view (reservation_customer_id, reservation_number_of_adults, reservation_number_of_children, reservation_price_gross, reservation_start_date, reservation_end_date, reservation_room_id)
VALUES
    (1,1,1,1,'2025-03-01','2025-03-21',1);

