/*
FOR TESTING ONLY
*/

INSERT INTO user_account(user_name, password,e_mail)
VALUES
    ('aaaOne','bbb','ONE@wp.pl'),
    ('aaaTwo','bbb','TWO@wp.pl'),
    ('aaaThree','bbb','THREE@wp.pl');


INSERT INTO user_details(user_id, nip_num, name, surname, phone_num, city, postal_code, street, building_num)
VALUES
    (1,NULL,'ONEaaa','ONEbbb','+48123456789','LDZ','12-324','ONEplpl','12'),
    (2,NULL,'TWOaaa','TWObbb','+48123456789','WWA','10-944','TWOplpl','22'),
    (3,NULL,'THREEaaa','THREEbbb','+48123456789','GDA','10-881','THREEplpl','33');


INSERT INTO room_type(num_of_single_beds, num_of_double_beds, num_of_child_beds, Adult_price_gross, Child_price_gross, photos_dir)
VALUES 
    (0,1,1,20,10,'/'),
    (1,0,0,5,0,'/');


INSERT INTO room(id,room_type_id,room_price_gross)
VALUES 
    (1,1,10),
    (2,1,20),
    (3,1,30),
    (4,1,40);
