/*
    Test query to update customer e-mail,
    will not work, because e_mail is set / change via dedicated function
    Expected result: fail
*/

UPDATE customer_view
SET customer_email = 'jan.kowal@wp.pl'
WHERE customer_id = 1;