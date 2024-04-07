/*
    Test query insert new user account
    Expected result: fail
*/

INSERT INTO user_view (user_e_mail, user_name, user_is_active, user_is_admin)
VALUES ('Ninser@wp.pl','newInsUsr', TRUE, FALSE);