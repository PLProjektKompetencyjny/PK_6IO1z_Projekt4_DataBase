/*
    .DESCRIPTION
        SQL script for PostgreSQL to define DELETE functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is supposed to define all delete functions,
        which will be used in INSTEAD OF DELETE view triggers.

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Delete function must have a prefix 'delete_' followed by <view_name> in the name. 
            Because all functions are located in the common Object explorer directory.

        - Delete function must return NULL if operation was successful, 
            otherwise raise an descriptive exception, which will be capture by backend.

        - Delete function can be written in SQL or PL/Python, both languages are supported,
            however RECOMMENDED FOR DATA MODIFICATION IS SQL.

        - Delete function must handle everything related to removing record from DB,
            including any additionally required cleanup.


    .NOTES

        Version:            1.6
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      18-Mar-2024
        ChangeLog:

        Date            Who                     What
        2024-03-22      Stanisław Horna         delete_operation_not_permitted generic func for all not permitted ops.

        2024-05-25      Stanisław Horna         add delete_reservation_view()

        2024-05-28      Stanisław Horna         add custom SQLSTATE to exceptions.

        2024-06-30      Stanisław Horna         add delete_service_view(), remove reservation entry if no room is assigned

        2024-07-01      Stanisław Horna         add SECURITY DEFINER <- to invoke functions with owner's permissions, 
                                                    instead of caller ones.

*/

CREATE OR REPLACE FUNCTION delete_operation_not_permitted()
RETURNS TRIGGER AS $$
BEGIN

    RAISE EXCEPTION 'Operation not permitted.'
    USING ERRCODE = '23999';

	RETURN NULL;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION delete_reservation_view()
RETURNS TRIGGER AS $$
BEGIN

    DELETE FROM RESERVATION_ROOM
    WHERE
        ROOM_ID = OLD.RESERVATION_ROOM_ID
        AND RESERVATION_ID = OLD.RESERVATION_ID;

    IF NOT EXISTS (
        SELECT
            ROOM_ID
        FROM RESERVATION_ROOM
        WHERE RESERVATION_ID = OLD.RESERVATION_ID
    ) THEN
        DELETE FROM RESERVATION_SERVICE
        WHERE RESERVATION_ID = OLD.RESERVATION_ID;

        DELETE FROM RESERVATION
        WHERE ID = OLD.RESERVATION_ID;

    END IF;

	RETURN NULL;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION delete_service_view()
RETURNS TRIGGER AS $$
BEGIN

    DELETE FROM RESERVATION_SERVICE
    WHERE
        SERVICE_ID = OLD.SERVICE_ID
        AND RESERVATION_ID = OLD.SERVICE_RESERVATION_ID;

	RETURN NULL;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;