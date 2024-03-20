/*
    .DESCRIPTION
        SQL script for PostgreSQL to INSERT enum values ('dict_' table prefix) in TravelNest DB.
        EXISTING VALUES WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

		Following actions will be performed in a given order:
			1. INSERT new enum values for following dict tables:
                - dict_reservation_status
                - dict_invoice_status
                - dict_room_status


    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      20-Mar-2024
        ChangeLog:

        Date            Who                     What

*/


INSERT INTO dict_reservation_status (id, Status_value)
VALUES
    (1,'WAITING_CONFIRMATION'),
    (2,'WAITING_PAYMENT'),
    (3,'CONFIRMED'),
    (4,'CANCELLED'),
    (5, 'CHECKED_IN'),
    (6,'CHECKED_OUT'),
    (7,'NO_SHOW');


INSERT INTO dict_invoice_status (id, Status_value)
VALUES 
    (1,'DRAFT'),
    (2,'SENT'),
    (3,'WAITING_PAYMENT'),
    (4,'PAID'),
    (5,'CANCELLED'),
    (6,'CORRECTION');


INSERT INTO dict_room_status (id, Status_value)
VALUES 
    (1,'AVAILABLE'),
    (2,'OCCUPIED'),
    (3,'RESERVED'),
    (4,'OUT_OF_ORDER'),
    (5,'MAINTENANCE');
