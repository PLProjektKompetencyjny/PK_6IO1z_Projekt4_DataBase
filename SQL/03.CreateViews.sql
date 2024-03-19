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
	d.User_ID AS "Customer_ID",
	d.Nip_num AS "Customer_NIP_Number",
	d.Name AS "Customer_Name",
	d.Surname AS "Customer_Surname",
	d.E_mail AS "Customer_Email",
	d.Phone_num AS "Customer_Phone",
	d.City AS "Customer_City",
	d.Postal_code AS "Customer_Postal_Code",
	d.Street AS "Customer_Street",
	d.Building_num AS "Customer_Building_Number",
	d.Last_modified_by AS "Customer_Last_Modified_by",
	d.Last_modified_at AS "Customer_Last_Modified_at"
FROM User_Details d;

CREATE VIEW reservation_view AS
SELECT
	r.ID AS "Reservation_ID",
	r.Customer_ID AS "Reservation_Customer_ID",
	s.Status_value AS "Reservation_Status",
	s.ID AS "Reservation_Status_ID",
	r.Num_of_adults AS "Reservation_Number_of_Adults",
	r.Num_of_children AS "Reservation_Number_of_Children",
	r.Start_date AS "Reservation_Start_Date",
	r.End_date AS "Reservation_End_Date",
	r.Price_gross AS "Reservation_Price_Gross",
	r.Is_paid AS "Reservation_Is_Paid",
	rr.Room_ID AS "Reservation_Room_ID"
FROM Reservation r
LEFT JOIN Reservation_room rr ON rr.Reservation_ID = r.ID
LEFT JOIN dict_reservation_status s ON s.ID = r.Status_ID;

CREATE VIEW room_view AS
SELECT
	r.ID AS "Room_ID",
	s.ID AS "Room_Status_ID",
	s.Status_value AS "Room_Status",
	t.Num_of_single_beds AS "Room_Number_of_Single_Beds", 
	t.Num_of_double_beds AS "Room_Number_of_Double_Beds",
	t.Num_of_child_beds AS "Room_Number_of_Child_Beds", 
	t.Room_price_gross AS "Room_Gross_Price", 
	t.Adult_price_gross AS "Room_Gross_Price_Adult", 
	t.Child_price_gross AS "Room_Gross_Price_Child", 
	t.Phots_dir AS "Room_Photos_Dir"
FROM Room r
LEFT JOIN dict_room_status s ON s.ID = r.status_ID
LEFT JOIN Room_Type t ON t.ID = r.Room_type_ID;

CREATE VIEW invoice_view AS
SELECT
    i.ID AS "Invoice_ID",
    i.Reservation_ID AS "Invoice_Reservation_ID",
    i.Invoice_date AS "Invoice_Date",
	s.ID AS "Invoice_Status_ID",
    s.Status_value AS "Invoice_Status"
FROM Invoice i
LEFT JOIN dict_invoice_status s ON s.ID = i.status_ID;

CREATE VIEW user_view AS
SELECT
    u.ID AS "User_ID",
    u.User_name AS "User_Name",
    u.Is_Active AS "User_Is_Active",
    u.Is_Admin AS "User_Is_Admin",
	u.Last_modified_by AS "User_Last_Modified_by",
	u.Last_modified_at AS "User_Last_Modified_at"
FROM user_account u;

