/*
    .DESCRIPTION
        SQL script for PostgreSQL to define sub functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is supposed to define all sub functions (related to reservation),
        which will be used in another functions, most likely those executed by triggers.

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Sub function can be written in SQL or PL/Python, both languages are supported,
            decision which one to use is made by person who need to use it.


    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      24-May-2024
        ChangeLog:

        Date            Who                     What


*/

CREATE OR REPLACE FUNCTION check_room_availability(room_to_check_id int, new_reservation_start_date timestamp, new_reservation_end_date timestamp) 
RETURNS int 
AS $$
BEGIN

    -- check if input is not null
    IF room_to_check_id IS NULL THEN
        RAISE EXCEPTION 'Room ID cannot be NULL';
        RETURN -1;
    END IF;

    -- check if input is not null
    IF new_reservation_start_date IS NULL THEN
        RAISE EXCEPTION 'Start date cannot be NULL';
        RETURN -1;
    END IF;

    -- check if input is not null
    IF new_reservation_end_date IS NULL THEN
        RAISE EXCEPTION 'End date cannot be NULL';
        RETURN -1;
    END IF;

    -- check if provided room id exists
    IF NOT EXISTS (
        SELECT
            ID
        FROM ROOM
    ) THEN
        RAISE EXCEPTION 'Room does not exist';
        RETURN -1;
    END IF;


    -- check if room is not already booked
    IF EXISTS (
        SELECT
            RESERVATION_ID
        FROM
            RESERVATION_VIEW
        WHERE
            RESERVATION_ROOM_ID = room_to_check_id
            AND (
                (   
                    -- check if there is an existing reservation which starts or ends
                    -- in period selected for new reservation
                    RESERVATION_START_DATE BETWEEN new_reservation_start_date AND new_reservation_end_date
                    OR RESERVATION_END_DATE BETWEEN new_reservation_start_date AND new_reservation_end_date
                )
                OR (
                    -- check if new reservation is inside of existing reservation
                    RESERVATION_START_DATE < new_reservation_start_date
                    AND RESERVATION_END_DATE > new_reservation_end_date
                )
            )
    ) THEN
        RAISE EXCEPTION 'Room % is already booked in provided time frame', room_to_check_id;
        RETURN -1;
    END IF;
    
    RETURN room_to_check_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- CREATE OR REPLACE FUNCTION check_room_guest_number(room_to_check_id int, reservation_id_to_check int) 
-- RETURNS int 
-- AS $$
-- BEGIN

-- END;