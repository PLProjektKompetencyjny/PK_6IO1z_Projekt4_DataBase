/*
    Test query to insert reservation with 3 Rooms
    Expected result: success
*/

INSERT INTO room_view(room_id,room_type_id,room_gross_price)
VALUES 
    (7,2,1000),
    (8,2,200),
    (9,2,700);
