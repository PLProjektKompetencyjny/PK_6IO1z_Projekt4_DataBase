/*
    Test query to insert new rooms in bulk
    Expected result: success
*/

INSERT INTO room_view(room_id,room_type_id,room_gross_price)
VALUES 
    (5,1,1000),
    (6,1,200);
