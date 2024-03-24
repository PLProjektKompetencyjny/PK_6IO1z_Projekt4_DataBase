/*
    Test query to insert customer details for customer 1
    Expected result: success
*/

UPDATE customer_view
SET     
    customer_city = 'Warszawa',
    customer_postal_code = '01-123',
    customer_street = 'Mickiewicza',
    customer_building_number = '134 A'
WHERE customer_id = 1;