/*
    .DESCRIPTION
        SQL script for PostgreSQL to configure TravelNest DB.
        EXISTING DB WILL BE REMOVED AND CREATED FROM SCARTCH.

    .NOTES

        Version:            1.1
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      16-Mar-2024
        ChangeLog:

        Date            Who                     What
		2024-03-17		Stanisław Horna			Removed Description column from "dict_" tables.

*/

-- Removing existing tables
DROP TABLE IF EXISTS Admins;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Addresses;
DROP TABLE IF EXISTS Reservations;
DROP TABLE IF EXISTS ReservationRooms;
DROP TABLE IF EXISTS dict_reservation_status;
DROP TABLE IF EXISTS Invoice;
DROP TABLE IF EXISTS dict_invoice_status;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS RoomType;
DROP TABLE IF EXISTS dict_room_status;


-- Creating tables
CREATE TABLE Admins (
	ID serial primary key NOT NULL,
	user_name varchar NOT NULL,
	password varchar NOT NULL,
	isActive bool DEFAULT true,
	E_mail varchar NOT NULL,
	Phone_num varchar NOT NULL,
	Creation_date timestamp DEFAULT now()

	CONSTRAINT chk_UserName CHECK (user_name ~ '^[a-zA-Z]+$'),
	CONSTRAINT chk_Email CHECK (E_mail ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
	CONSTRAINT chk_Phone CHECK (Phone_num ~ '^\+\d{11}$')
);

CREATE TABLE Customers (
	ID serial PRIMARY KEY NOT NULL,
	NIP_num varchar NULL,
	Name varchar NOT NULL,
	Surname varchar NULL,
	Adress_ID int NOT NULL,
	E_mail varchar NOT NULL,
	Password varchar NOT NULL,
	Phone_num varchar NOT NULL,
	Creation_date timestamp DEFAULT now()

	CONSTRAINT chk_NipNum CHECK (check_nip_number(NIP_num)),
	CONSTRAINT chk_Name CHECK (Name ~ '^[a-zA-Z]+$'),
	CONSTRAINT chk_Surname CHECK (Surname ~ '^[a-zA-Z]+$'),
	CONSTRAINT chk_Email CHECK (E_mail ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
	CONSTRAINT chk_Phone CHECK (Phone_num ~ '^\+\d{11}$')
);

CREATE TABLE Addresses (
	ID serial PRIMARY KEY NOT NULL,
	City varchar NOT NULL,
	Postal_Code varchar NOT NULL,
	Street varchar NOT NULL,
	Building_num varchar NOT NULL,

	CONSTRAINT chk_City CHECK (City ~ '^[a-zA-Z]+$'),
	CONSTRAINT chk_PostalCode CHECK (Postal_Code ~ '^\d{2}-\d{3}$'),
	CONSTRAINT chk_Street CHECK (Street ~ '^[a-zA-Z]+$'),
	CONSTRAINT chk_BuildingNum CHECK (Building_num ~ '^\d+(\s[A-Za-z])?$')
);

CREATE TABLE Reservations (
	ID serial PRIMARY KEY NOT NULL,
	Customer_ID int NOT NULL,
	Status_ID int NOT NULL,
	Room_ID int NOT NULL,
	Num_of_adults int NOT NULL,
	Num_of_children int NOT NULL,
	Start_date timestamp NOT NULL,
	End_date timestamp NOT NULL,
	Price_gross float NOT NULL,
	isPaid bool DEFAULT false,
	Creation_date timestamp DEFAULT now(),

	CONSTRAINT chk_NumOfAdults CHECK (Num_of_adults >= 1),
	CONSTRAINT chk_NumOfChildren CHECK (Num_of_children >= 0),
	CONSTRAINT chk_StartDate CHECK (Start_date > NOW()),
	CONSTRAINT chk_EndDate CHECK (End_date > NOW()),
	CONSTRAINT chk_ReservationDates CHECK (End_date > Start_date),
	CONSTRAINT chk_PriceGross CHECK (Price_gross >= 0)
);

CREATE TABLE ReservationRooms (
	ID int NOT NULL,
	Room_ID int NOT NULL,

	CONSTRAINT ReservationRooms_pkey PRIMARY KEY (ID,Room_ID)
);

CREATE TABLE dict_reservation_status (
	ID int PRIMARY KEY NOT NULL,
	Name varchar NOT NULL
);

CREATE TABLE Invoice (
	ID serial PRIMARY KEY NOT NULL,
	Reservation_ID int NOT NULL,
	Invoice_Date timestamp DEFAULT now(),
	Status_ID int DEFAULT 0
);

CREATE TABLE dict_invoice_status (
	ID int PRIMARY KEY NOT NULL,
	Name varchar NOT NULL
);

CREATE TABLE Room (
	ID serial PRIMARY KEY NOT NULL,
	RoomType int NOT NULL,
	Status_ID int DEFAULT 0
);

CREATE TABLE RoomType (
	ID serial PRIMARY KEY NOT NULL,
	Num_of_single_beds int NOT NULL,
	Num_of_double_beds int NOT NULL,
	Num_of_child_beds int NOT NULL,
	Room_price_gross float NOT NULL,
	Adult_price_gross float NOT NULL,
	Child_price_gross float NOT NULL,
	Phots_dir varchar NOT NULL


	CONSTRAINT chk_NumOfSingleBeds CHECK (Num_of_single_beds >= 0),
	CONSTRAINT chk_NumOfDoubleBeds CHECK (Num_of_double_beds >= 0),
	CONSTRAINT chk_NumOfChildBeds CHECK (Num_of_child_beds >= 0),
	CONSTRAINT chk_RoomPriceGross CHECK (Room_price_gross >= 0),
	CONSTRAINT chk_AdultPriceGross CHECK (Adult_price_gross >= 0),
	CONSTRAINT chk_ChildPriceGross CHECK (Child_price_gross >= 0)
);

CREATE TABLE dict_room_status (
	ID int PRIMARY KEY NOT NULL,
	Name varchar NOT NULL
);

