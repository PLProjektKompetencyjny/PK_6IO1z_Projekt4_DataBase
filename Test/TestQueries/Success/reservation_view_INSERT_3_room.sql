/*
    Test query to insert reservation with 3 Rooms for room ids 1, 2, 3
    Expected result: success
*/

INSERT INTO reservation_view (
    reservation_customer_id, 
    reservation_number_of_adults, 
    reservation_number_of_children,  
    reservation_start_date, 
    reservation_end_date, 
    reservation_room_id
    )
VALUES
    (3,1,1,'2025-03-21','2025-04-22',1),
	(3,1,1,'2025-03-21','2025-04-22',2),
	(3,1,1,'2025-03-21','2025-04-22',3);

