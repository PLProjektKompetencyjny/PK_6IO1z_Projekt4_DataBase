/*
    Test query to insert reservation with 3 Rooms
    Expected result: success
*/

INSERT INTO room(id,room_type_id,room_price_gross)
VALUES 
    (7,2,1000),
    (8,2,200),
    (9,2,700);
