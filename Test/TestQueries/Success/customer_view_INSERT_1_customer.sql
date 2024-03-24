/*
    Test query to insert customer details for customer 1
    Expected result: success
*/


INSERT INTO customer_view (
    customer_id, 
    customer_name, 
    customer_surname, 
    customer_phone, 
    customer_city,
    customer_postal_code,
    customer_street,
    customer_building_number
    )
VALUES (
    4,
    'John',
    'Kowalsky',
    '+48123456789',
    'Lodz',
    '11-792',
    'Piotrkowska',
    '38'
);