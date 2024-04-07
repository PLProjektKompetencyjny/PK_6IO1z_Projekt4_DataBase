/*
    Test query to update reservation number of guests, both adults and childs for reservation 3
    Expected result: success
*/


UPDATE reservation_view 
SET 
	reservation_number_of_children = 4,
    reservation_number_of_adults = 2
WHERE reservation_id = 3;
