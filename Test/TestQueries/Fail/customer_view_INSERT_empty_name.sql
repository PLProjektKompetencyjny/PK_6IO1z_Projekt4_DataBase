/*
    Test query to insert customer details, missing name which is mandatory
    Expected result: fail
*/

INSERT INTO customer_view (
    customer_id
    customer_surname, 
    customer_phone, 
    customer_city,
    customer_postal_code,
    customer_street,
    customer_building_number
    )
VALUES (
    2,
    'Kowal',
    '+48123456789',
    'Łódź',
    '11-792',
    'Piotrkowska',
    '38'
);