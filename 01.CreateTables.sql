/*
    .DESCRIPTION
        SQL script for PostgreSQL to configure TravelNest DB.
        EXISTING DB WILL BE REMOVED AND CREATED FROM SCARTCH.

    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      16-Mar-2024
        ChangeLog:

        Date            Who                     What

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
	isActive bool NOT NULL,
	E_mail varchar NOT NULL,
	Phone_num varchar NOT NULL,
	Creation_date timestamp DEFAULT now()
)

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
);

CREATE TABLE Addresses (
	ID serial PRIMARY KEY NOT NULL,
	City varchar NOT NULL,
	Postal_Code varchar NOT NULL,
	Street varchar NOT NULL,
	Building_num int NOT NULL
);

CREATE TABLE Reservations (
	ID serial PRIMARY KEY NOT NULL,
	Customer_ID int NOT NULL,
	Status_ID int NOT NULL,
	Room_ID int NOT NULL,
	Num_of_adults int NOT NULL,
	Num_of_childs int NOT NULL,
	Start_date timestamp NOT NULL,
	End_date timestamp NOT NULL,
	Price_gross float NOT NULL,
	isPaid bool DEFAULT false,
	Creation_date timestamp DEFAULT now()
);

CREATE TABLE ReservationRooms (
	ID int NOT NULL,
	Room_ID int NOT NULL
);

CREATE TABLE dict_reservation_status (
	ID int PRIMARY KEY NOT NULL,
	Name varchar NOT NULL,
	Description varchar NULL
);

CREATE TABLE Invoice (
	ID serial PRIMARY KEY NOT NULL,
	Reservation_ID int NOT NULL,
	Invoice_Date timestamp NOT NULL,
	Status int NOT NULL
);

CREATE TABLE dict_invoice_status (
	ID int PRIMARY KEY NOT NULL,
	Name varchar NOT NULL,
	Description varchar NULL
);

CREATE TABLE Room (
	ID serial PRIMARY KEY NOT NULL,
	RoomType int NOT NULL,
	Status_ID int NOT NULL
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
);

CREATE TABLE dict_room_status (
	ID int PRIMARY KEY NOT NULL,
	Name varchar NOT NULL,
	Description varchar NULL
);

