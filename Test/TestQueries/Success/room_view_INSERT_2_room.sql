/*
    Test query to insert new rooms in bulk
    Expected result: success
*/

INSERT INTO room(id,room_type_id,room_price_gross)
VALUES 
    (5,1,1000),
    (6,1,200);
