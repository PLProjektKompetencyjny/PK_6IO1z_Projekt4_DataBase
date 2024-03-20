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

		- Aliases for VIEW columns must contain view name, column name in format:
			<view_name>_<column_name>


    .NOTES

        Version:            1.1
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      17-Mar-2024
        ChangeLog:

        Date            Who                     What
		2024-03-18		Stanisław Horna			Update views based on tables re-desing
						Grzegorz Kubicki		Passwords excluded from views,
												DB will be responsible for checking if password is correct.
*/

-- Drop existing Views
DROP VIEW IF EXISTS customer_view;
DROP VIEW IF EXISTS reservation_view;
DROP VIEW IF EXISTS room_view;
DROP VIEW IF EXISTS invoice_view;
DROP VIEW IF EXISTS user_view;


-- Create Views
CREATE VIEW customer_view AS
SELECT
	d.User_id AS "customer_id",
	d.Nip_Num AS "customer_nip_number",
	d.Name AS "customer_name",
	d.Surname AS "customer_surname",
	d.E_Mail AS "customer_email",
	d.Phone_Num AS "customer_phone",
	d.City AS "customer_city",
	d.Postal_code AS "customer_postal_code",
	d.Street AS "customer_street",
	d.Building_Num AS "customer_building_number",
	d.Last_Modified_by AS "customer_last_modified_by",
	d.Last_Modified_at AS "customer_last_modified_at"
FROM User_Details d;

CREATE VIEW reservation_view AS
SELECT
	r.ID AS "reservation_id",
	r.Customer_ID AS "reservation_customer_id",
	s.Status_value AS "reservation_status",
	s.ID AS "reservation_status_id",
	r.Num_of_Adults AS "reservation_number_of_adults",
	r.Num_of_Children AS "reservation_number_of_children",
	r.Start_Date AS "reservation_start_date",
	r.End_Date AS "reservation_end_date",
	r.Price_Gross AS "reservation_price_gross",
	r.Is_Paid AS "reservation_is_paid",
	rr.Room_ID AS "reservation_room_id",
	r.Last_Modified_by AS "reservation_last_modified_by",
	r.Last_Modified_at AS "reservation_last_modified_at"
FROM Reservation r
LEFT JOIN reservation_room rr ON rr.reservation_id = r.ID
LEFT JOIN dict_reservation_status s ON s.ID = r.Status_id;

CREATE VIEW room_view AS
SELECT
	r.ID AS "room_id",
	s.ID AS "room_status_id",
	s.Status_Value AS "room_status",
	t.Num_of_Single_Beds AS "room_number_of_single_beds", 
	t.Num_of_Double_Beds AS "room_number_of_double_beds",
	t.Num_of_Child_Beds AS "room_number_of_child_beds", 
	t.Room_Price_Gross AS "room_gross_price", 
	t.Adult_Price_Gross AS "room_Gross_price_adult", 
	t.Child_Price_Gross AS "room_Gross_price_child", 
	t.Phots_Dir AS "room_photos_dir",
	r.Last_Modified_by AS "room_last_modified_by",
	r.Last_Modified_at AS "room_last_modified_at"
FROM Room r
LEFT JOIN dict_room_status s ON s.ID = r.status_id
LEFT JOIN Room_Type t ON t.ID = r.Room_type_id;

CREATE VIEW invoice_view AS
SELECT
    i.ID AS "invoice_id",
    i.Reservation_ID AS "invoice_reservation_id",
    i.Invoice_Date AS "invoice_date",
	s.ID AS "invoice_status_id",
    s.Status_Value AS "invoice_status",
	i.Last_Modified_by AS "invoice_last_modified_by",
	i.Last_Modified_at AS "invoice_last_modified_at"
FROM Invoice i
LEFT JOIN dict_invoice_status s ON s.ID = i.status_id;

CREATE VIEW user_view AS
SELECT
    u.ID AS "user_id",
    u.User_Name AS "user_Name",
    u.Is_Active AS "user_is_active",
    u.Is_Admin AS "user_is_admin",
	u.Last_Modified_by AS "user_last_modified_by",
	u.Last_Modified_at AS "user_last_modified_at"
FROM user_account u;

