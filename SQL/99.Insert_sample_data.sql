/*
FOR TESTING ONLY
*/


INSERT INTO user_account(user_name, password,e_mail)
VALUES('aaa','bbb','ss@wp.pl');

INSERT INTO user_details(user_id, nip_num, name, surname, phone_num, city, postal_code, street, building_num)
VALUES(1,NULL,'aaa','bbb','+48733463216','LDZ','12-324','plpl','1');

INSERT INTO room_type(num_of_single_beds, num_of_double_beds, num_of_child_beds, Adult_price_gross, Child_price_gross, photos_dir)
VALUES (0,1,1,5,8,'/');

INSERT INTO dict_room_status(id, status_value)
VALUES(0, 'Ready');

INSERT INTO room(id,room_type_id,room_price_gross)
VALUES (1,1,10);

INSERT INTO room(id,room_type_id,room_price_gross)
VALUES (2,1,10);
	
INSERT INTO dict_reservation_status(id, status_value)
VALUES(0, 'Ready');

