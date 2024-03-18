/*
    .DESCRIPTION
        SQL script for PostgreSQL to configure Views in TravelNest DB.
        EXISTING DB VIEWS WILL BE REMOVED AND PRIVILEGES WILL BE FLUSHED.

            SQL script for PostgreSQL to configure Tables in TravelNest DB.
        EXISTING DB TABLES WILL BE REMOVED AND DATA WILL BE LOST.

		Following actions will be performed in a given order:
			1. DROP of all TravelNest Views.
			2. CREATE all Views from scratch.

	.RULES
		- DROP VIEW must include IF EXISTS.

		- Required columns must be defined with table alias for better visibility.

		- No WHERE clauses, should be included on Backend side

    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      17-Mar-2024
        ChangeLog:

        Date            Who                     What

*/

-- Drop existing Views
DROP VIEW IF EXISTS customer_view;
DROP VIEW IF EXISTS reservation_view;
DROP VIEW IF EXISTS room_view;
DROP VIEW IF EXISTS invoice_view;
DROP VIEW IF EXISTS admin_view;


-- Create Views
CREATE VIEW customer_view AS
SELECT
	c.ID,
	c.NIP_num,
	c.Name,
	c.Surname,
    c.Password,
	c.E_mail,
	c.Phone_num,
	a.City,
	a.Postal_code,
	a.Street,
	a.Building_num
FROM Customer c
LEFT JOIN Address a ON a.ID = c.Address_ID;

CREATE VIEW reservation_view AS
SELECT
	r.ID,
	r.customer_ID,
	s.status_value,
	r.num_of_adults,
	r.num_of_children,
	r.start_date,
	r.end_date,
	r.price_gross,
	r.is_paid,
	rr.Room_ID
FROM Reservation r
LEFT JOIN Reservation_room rr ON rr.Reservation_ID = r.ID
LEFT JOIN dict_reservation_status s ON s.ID = r.status_ID;

CREATE VIEW room_view AS
SELECT
	r.ID,
	s.status_value,
	t.Num_of_single_beds, 
	t.Num_of_double_beds,
	t.Num_of_child_beds, 
	t.Room_price_gross, 
	t.Adult_price_gross, 
	t.Child_price_gross, 
	t.Phots_dir
FROM Room r
LEFT JOIN dict_room_status s ON s.ID = r.status_ID
LEFT JOIN Room_type t ON t.ID = r.room_type_ID;

CREATE VIEW invoice_view AS
SELECT
    i.ID,
    i.reservation_ID,
    i.invoice_date,
    s.status_value
FROM Invoice i
LEFT JOIN dict_invoice_status s ON s.ID = i.status_ID;

CREATE VIEW admin_view AS
SELECT
    a.ID,
    a.user_name,
    a.password,
    a.is_Active,
    a.e_mail,
    a.Phone_num
FROM Admin a;

