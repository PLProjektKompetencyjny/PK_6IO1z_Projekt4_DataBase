/*
    Test query to insert reservation with 2 Rooms for room ids 1 and 2
    Expected result: success
*/
INSERT INTO reservation_view (
    reservation_customer_id, 
    reservation_number_of_adults, 
    reservation_number_of_children, 
    reservation_start_date, 
    reservation_end_date, 
    reservation_room_id)
VALUES
    (2,1,1,'2025-03-03','2025-03-24',1),
    (2,1,1,'2025-03-03','2025-03-24',2);
