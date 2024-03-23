/*
    .DESCRIPTION
        SQL script for PostgreSQL to configure Tables in TravelNest DB.
        EXISTING DB TABLES WILL BE REMOVED AND DATA WILL BE LOST.

		Following actions will be performed in a given order:
			1. DROP of all TravelNest Tables.
			2. CREATE all Tables from scratch,
				create CHECK CONSTRAINT
			3. ADD FOREIGN KEY for each table
			4. INSERT static data:
				- dictionary entries (tables with prefix 'dict_' in the name)
				- Default user in user account called 'SYSTEM'


	.RULES
		- DROP TABLE must include IF EXISTS, as well as CASCADE.

		- DEFAULT must be included in CREATE TABLE in the same line as column definition, which it is related to.

		- CHECK constraint must be included in CREATE TABLE instruction after columns definition in format:
			CONSTRAINT <check_name>_chk CHECK (<Expression_to_check>).

		- FOREIGN KEY must be added at the last section of the file in format: 
			ALTER TABLE <table_name>
			ADD CONSTRAINT <foreign_key_name>_fkey FOREIGN KEY (<column_name>)
			REFERENCES <foreign_table_name> (<foreign_column_name>) MATCH SIMPLE;
		
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

		- Constraints' suffixes:
			- PRIMARY KEY 	<- suffix '_pkey'
			- FOREIGN KEY 	<- suffix '_fkey'
			- CHECK 		<- suffix '_chk'

		- Constraints' names:
			- PRIMARY KEY 	<- must have same name as table name + appropriate suffix.
			- FOREIGN KEY 	<- must have same name as column, which it is related to, 
								skipping column name suffix which for fkeys must be '_ID' + appropriate suffix.
			- CHECK 		<- must have same name as column, which it is related to + appropriate suffix.
								If CHECK is related to more then 1 column, name can be custom to describe,
								what does it check + appropriate suffix.


    .NOTES

        Version:            1.2
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      16-Mar-2024
        ChangeLog:

        Date            Who                     What
		2024-03-17		Stanisław Horna			Removed Description column from "dict_" tables.
												Unified naming:
													- word separation in names with '_'
													- table names changed to singular form
													- columns with foreign keys ends with '_ID'
												Basic check constraints and Foreign keys added.
												CASCADE added to each DROP instruction, to remove all related objects

		2024-03-18		Stanisław Horna			Re-design of address, customer, admin tables.
						Grzegorz Kubicki		Switched to approach where login credentials,
												for both customers and admins are stored in user_account table.
												User_details store customer related information, 
												which are not required for admin account
		
		2024-03-20		Stanisław Horna			Removed auto-gen id in Room table.
		2024-03-22		Stanisław Horna			Additional constraint to check if user_name or e_mail is provided.
												fkeys for last_modified_by added.

		2024-03-23		Stanisław Horna			Is_Paid and Price_gross moved from reservation to invoice table

*/

-- Drop existing tables
DROP TABLE IF EXISTS User_Account CASCADE;
DROP TABLE IF EXISTS User_Details CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Reservation_Room CASCADE;
DROP TABLE IF EXISTS dict_reservation_status CASCADE;
DROP TABLE IF EXISTS Invoice CASCADE;
DROP TABLE IF EXISTS dict_invoice_status CASCADE;
DROP TABLE IF EXISTS Room CASCADE;
DROP TABLE IF EXISTS Room_Type CASCADE;
DROP TABLE IF EXISTS dict_room_status CASCADE;


-- Create tables
CREATE TABLE User_Account (
	ID serial primary key NOT NULL,
	E_mail varchar UNIQUE NULL, -- can be null (admins do not have to have one), unique - auth method for customers
	User_name varchar UNIQUE NULL, -- can be null (customers do not have one), unique - auth method for admins
	Password varchar NOT NULL,
	Is_active bool DEFAULT TRUE,
	Is_admin bool DEFAULT FALSE,
	Creation_date timestamp DEFAULT now(),
	Last_modified_at timestamp DEFAULT now(),
	Last_modified_by int NULL,

	CONSTRAINT E_mail_chk CHECK (validate_e_mail(E_mail)), -- check if email is matching regex pattern
	CONSTRAINT User_name_chk CHECK (User_name ~ '^[a-zA-Z]+$'), -- username contains letters only
	-- check if user or email is present
	CONSTRAINT E_mail_OR_User_name_chk CHECK (user_name IS NOT NULL OR E_mail IS NOT NULL) 
);

CREATE TABLE User_Details (
	User_ID int UNIQUE NOT NULL, -- no pkey, as it matches ID from User_Account
	NIP_num varchar NULL,
	Name varchar NOT NULL, -- can not be null as company name should be stored here if customer is company
	Surname varchar NULL,
	Phone_num varchar NOT NULL,
	City varchar NOT NULL,
	Postal_code varchar NOT NULL,
	Street varchar NOT NULL,
	Building_num varchar NOT NULL,
	Creation_date timestamp DEFAULT now(),
	Last_modified_at timestamp DEFAULT now(),
	Last_modified_by int NULL,

	CONSTRAINT Nip_Num_chk CHECK (NIP_num ~ '^\d{10}$'), -- check if contains 10 digits only
	CONSTRAINT Name_chk CHECK (Name ~ '^[a-zA-Z]+$'), -- check if contains only letters
	CONSTRAINT Surname_chk CHECK (Surname ~ '^[a-zA-Z]+$'), -- check if contains only letters
	CONSTRAINT Phone_num_chk CHECK (Phone_num ~ '^\+\d{11}$'), -- check if starts with '+', has 2 code digits, 9 number 
	CONSTRAINT City_chk CHECK (City ~ '^[a-zA-Z]+$'), -- check if contains only letters
	CONSTRAINT Postal_code_chk CHECK (Postal_Code ~ '^\d{2}-\d{3}$'), -- check if contains 2 digits, '-' and 3 digits
	CONSTRAINT Street_chk CHECK (Street ~ '^[a-zA-Z]+$'), -- check if contains only letters
	CONSTRAINT Building_num_chk CHECK (Building_num ~ '^\d+(\s[A-Za-z])?$') -- check if contains digits or/and letters
);


CREATE TABLE Reservation (
	ID serial PRIMARY KEY NOT NULL,
	User_account_ID int NOT NULL,
	Status_ID int DEFAULT 1,
	Num_of_adults int NOT NULL,
	Num_of_children int NOT NULL,
	Start_date timestamp NOT NULL,
	End_date timestamp NOT NULL,
	Creation_date timestamp DEFAULT now(),
	Last_modified_at timestamp DEFAULT now(),
	Last_modified_by int NULL,

	CONSTRAINT Num_of_adults_chk CHECK (Num_of_adults >= 1), -- must be on reservation at least one
	CONSTRAINT Num_of_children_chk CHECK (Num_of_children >= 0),  -- can be on reservation
	CONSTRAINT Start_date_chk CHECK (Start_date > NOW()), -- can not be reserved for past
	CONSTRAINT End_date_chk CHECK (End_date > NOW()), -- can not be reserved for past
	CONSTRAINT Reservation_dates_chk CHECK (End_date > Start_date) -- must have duration
);

CREATE TABLE Reservation_Room ( -- to handle many rooms on the same reservation
	Reservation_ID int NOT NULL,
	Room_ID int NOT NULL,
	Room_status_ID int DEFAULT 1,

	CONSTRAINT Reservation_room_pkey PRIMARY KEY (Reservation_ID,Room_ID) -- 1 room cannot be book twice
																			-- on the same reservation
);

CREATE TABLE dict_reservation_room_status (
	ID int PRIMARY KEY NOT NULL,
	Status_value varchar NOT NULL
);

CREATE TABLE dict_reservation_status (
	ID int PRIMARY KEY NOT NULL,
	Status_value varchar NOT NULL
);

CREATE TABLE Invoice (
	ID serial PRIMARY KEY NOT NULL,
	Reservation_ID int UNIQUE NOT NULL, -- can be only 1 invoice for 1 reservation
	Invoice_date timestamp DEFAULT now(),
	Price_gross float NOT NULL,
	Is_paid bool DEFAULT FALSE,
	Status_ID int DEFAULT 1,
	Last_modified_at timestamp DEFAULT now(),
	Last_modified_by int NULL,
	
	CONSTRAINT Price_gross_chk CHECK (Price_gross > 0) -- can not be negative
);

CREATE TABLE dict_invoice_status (
	ID int PRIMARY KEY NOT NULL,
	Status_value varchar NOT NULL
);

CREATE TABLE Room (
	ID int PRIMARY KEY NOT NULL,
	Room_type_ID int NOT NULL,
	Status_ID int DEFAULT 1,
	Room_price_gross float NOT NULL,
	Last_modified_at timestamp DEFAULT now(),
	Last_modified_by int NULL

	CONSTRAINT Room_price_gross_chk CHECK (Room_price_gross > 0) -- must be positive
);

CREATE TABLE Room_Type (
	ID serial PRIMARY KEY NOT NULL,
	Num_of_single_beds int NOT NULL,
	Num_of_double_beds int NOT NULL,
	Num_of_child_beds int NOT NULL,
	Adult_price_gross float NOT NULL,
	Child_price_gross float NOT NULL,
	Photos_dir varchar NOT NULL,
	Last_modified_at timestamp DEFAULT now(),
	Last_modified_by int NULL,


	CONSTRAINT Num_of_single_beds_chk CHECK (Num_of_single_beds >= 0), -- can not be negative
	CONSTRAINT Num_of_double_beds_chk CHECK (Num_of_double_beds >= 0), -- can not be negative
	CONSTRAINT Num_of_child_beds_chk CHECK (Num_of_child_beds >= 0), -- can not be negative
	CONSTRAINT Adult_price_gross_chk CHECK (Adult_price_gross > 0), -- must be positive, reservation must have adult
	CONSTRAINT Child_price_gross_chk CHECK (Child_price_gross >= 0) -- can not be negative
);

CREATE TABLE dict_room_status (
	ID int PRIMARY KEY NOT NULL,
	Status_value varchar NOT NULL
);


-- Create foreign keys
ALTER TABLE User_Details		-- link login credentials with names, contact, addresses
ADD CONSTRAINT User_fkey FOREIGN KEY (User_ID) 
REFERENCES User_account (ID) MATCH SIMPLE;


ALTER TABLE Reservation			-- link who made booking
ADD CONSTRAINT User_fkey FOREIGN KEY (User_account_ID) 
REFERENCES User_account (ID) MATCH SIMPLE;

ALTER TABLE Reservation			-- available statuses
ADD CONSTRAINT Status_fkey FOREIGN KEY (Status_ID) 
REFERENCES dict_reservation_status (ID) MATCH SIMPLE;


ALTER TABLE Reservation_Room	-- for many rooms on same reservation
ADD CONSTRAINT Reservation_fkey FOREIGN KEY (Reservation_ID) 
REFERENCES Reservation (ID) MATCH SIMPLE;

ALTER TABLE Reservation_Room	-- link reservations with actual rooms
ADD CONSTRAINT Room_fkey FOREIGN KEY (Room_ID) 
REFERENCES Room (ID) MATCH SIMPLE;

ALTER TABLE Reservation_Room	-- available statuses
ADD CONSTRAINT Room_status_fkey FOREIGN KEY (Room_status_ID) 
REFERENCES dict_reservation_room_status (ID) MATCH SIMPLE;

ALTER TABLE Room 				-- available statuses
ADD CONSTRAINT Status_fkey FOREIGN KEY (Status_ID) 
REFERENCES dict_room_status (ID) MATCH SIMPLE;

ALTER TABLE Room 				-- link actual rooms with their types, pricing and facilities
ADD CONSTRAINT Type_fkey FOREIGN KEY (Room_Type_ID) 
REFERENCES Room_Type (ID) MATCH SIMPLE;


ALTER TABLE Invoice 			-- link invoice with reservation, customer etc.
ADD CONSTRAINT Reservation_fkey FOREIGN KEY (Reservation_ID) 
REFERENCES Reservation (ID) MATCH SIMPLE;

ALTER TABLE Invoice 			-- available statuses
ADD CONSTRAINT Status_fkey FOREIGN KEY (Status_ID) 
REFERENCES dict_invoice_status (ID) MATCH SIMPLE;

ALTER TABLE User_Account 		-- only known accounts can be modifiers
ADD CONSTRAINT last_modified_by_fkey FOREIGN KEY (last_modified_by) 
REFERENCES user_account (ID) MATCH SIMPLE;

ALTER TABLE User_Details 		-- only known accounts can be modifiers
ADD CONSTRAINT last_modified_by_fkey FOREIGN KEY (last_modified_by) 
REFERENCES user_account (ID) MATCH SIMPLE;

ALTER TABLE Reservation 		-- only known accounts can be modifiers
ADD CONSTRAINT last_modified_by_fkey FOREIGN KEY (last_modified_by) 
REFERENCES user_account (ID) MATCH SIMPLE;

ALTER TABLE Invoice 			-- only known accounts can be modifiers
ADD CONSTRAINT last_modified_by_fkey FOREIGN KEY (last_modified_by) 
REFERENCES user_account (ID) MATCH SIMPLE;

ALTER TABLE Room 				-- only known accounts can be modifiers
ADD CONSTRAINT last_modified_by_fkey FOREIGN KEY (last_modified_by) 
REFERENCES user_account (ID) MATCH SIMPLE;

ALTER TABLE Room_Type			-- only known accounts can be modifiers
ADD CONSTRAINT last_modified_by_fkey FOREIGN KEY (last_modified_by) 
REFERENCES user_account (ID) MATCH SIMPLE;
