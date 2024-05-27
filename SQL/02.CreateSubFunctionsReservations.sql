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

        Version:            1.1
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      24-May-2024
        ChangeLog:

        Date            Who                     What
        2024-05-25      Stanisław Horna         add check_room_guest_number()

        2024-05-27      Stanisław Horna         remove exception if room is busy in check_room_availability()

*/

CREATE OR REPLACE FUNCTION get_reservation_id(new_entry RECORD) 
RETURNS int 
AS $$
BEGIN
    -- One customer can have only 1 reservation for the same time frame and guests number.
    RETURN (
        SELECT
            ID
        FROM Reservation
        WHERE user_account_id = new_entry.reservation_customer_id AND
                start_date = new_entry.reservation_start_date AND
                end_date = new_entry.reservation_end_date
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE OR REPLACE FUNCTION check_room_availability(room_to_check_id int, new_reservation_start_date timestamp, new_reservation_end_date timestamp) 
RETURNS int 
AS $$
BEGIN

    -- check if input is not null
    IF room_to_check_id IS NULL THEN
        RAISE EXCEPTION 'Room ID cannot be NULL';
        RETURN NULL;
    END IF;

    -- check if input is not null
    IF new_reservation_start_date IS NULL THEN
        RAISE EXCEPTION 'Start date cannot be NULL';
        RETURN NULL;
    END IF;

    -- check if input is not null
    IF new_reservation_end_date IS NULL THEN
        RAISE EXCEPTION 'End date cannot be NULL';
        RETURN NULL;
    END IF;

    -- check if provided room id exists
    IF NOT EXISTS (
        SELECT
            ID
        FROM ROOM
    ) THEN
        RAISE EXCEPTION 'Room does not exist';
        RETURN NULL;
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
        RETURN NULL;
    END IF;
    
    RETURN room_to_check_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION check_room_guest_number(room_to_check_id int, reservation_id_to_check int) 
RETURNS void 
AS $$
BEGIN

    -- raise an exception if there is not enough beds for assigned adults to the room
    -- or there is not enough beds for assigned children.
    IF EXISTS (
        SELECT
            ROOM_ID
        FROM
            (
                -- select necessary data for provided room_id and reservation
                SELECT
                    RR.ROOM_ID,
                    (
                        RT.NUM_OF_SINGLE_BEDS + (RT.NUM_OF_DOUBLE_BEDS * 2)
                    ) AS "adult_space",
                    NUM_OF_CHILD_BEDS AS "child_space",
                    RR.NUM_OF_ADULTS,
                    RR.NUM_OF_CHILDREN
                FROM
                    RESERVATION_ROOM RR
                    LEFT JOIN ROOM R ON R.ID = RR.ROOM_ID
                    LEFT JOIN ROOM_TYPE RT ON RT.ID = R.ROOM_TYPE_ID
                WHERE
                    RESERVATION_ID = reservation_id_to_check
                    AND ROOM_ID = room_to_check_id
            )
        WHERE
            -- check if there are more adults then beds
            ADULT_SPACE < NUM_OF_ADULTS
            -- check if there are more children then beds
            OR CHILD_SPACE < NUM_OF_CHILDREN
    ) THEN
        RAISE EXCEPTION 'Too many people assigned to room id: %', room_to_check_id;
    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION calculate_reservation_room_price(room_to_calc_id int, reservation_to_calc_id int) 
RETURNS void 
AS $$
DECLARE
    Room_price_calculated float;
BEGIN

    -- calculate price gross for provided room and reservation id
    -- store the value in Room_price_calculated
    SELECT
        (
            (RR.NUM_OF_ADULTS * RT.ADULT_PRICE_GROSS) + (RR.NUM_OF_CHILDREN * RT.CHILD_PRICE_GROSS) + R.ROOM_PRICE_GROSS
        )
    INTO
        Room_price_calculated
    FROM
        RESERVATION_ROOM RR
        LEFT JOIN ROOM R ON R.ID = RR.ROOM_ID
        LEFT JOIN ROOM_TYPE RT ON RT.ID = R.ROOM_TYPE_ID
    WHERE
        RR.RESERVATION_ID = reservation_to_calc_id
        AND RR.ROOM_ID = room_to_calc_id;

    -- update the reservation room entry with calculated value
    UPDATE RESERVATION_ROOM
    SET
        RESERVATION_ROOM_PRICE_GROSS = ROOM_PRICE_CALCULATED
    WHERE
        RESERVATION_ID = RESERVATION_TO_CALC_ID
        AND ROOM_ID = ROOM_TO_CALC_ID;
        
        RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;