/*
    .DESCRIPTION
        SQL script for PostgreSQL to define sub functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is suposed to define all sub functions,
        which will be used in another functions, most likely those executed by triggers.

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Sub function must have a prefix 'subf_' followed by descriptive name what they are doing. 

        - Sub function can be written in SQL or PL/Python, both languages are supported,
            decision which one to use is made by person who need to use it.


    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      20-Mar-2024
        ChangeLog:

        Date            Who                     What

*/


CREATE OR REPLACE FUNCTION subf_get_reservation_id(new_entry RECORD) 
RETURNS int AS $$
BEGIN
    RETURN (
        SELECT
            ID
        FROM Reservation
        WHERE user_account_id = new_entry.reservation_customer_id AND
                num_of_adults = new_entry.reservation_number_of_adults AND
                num_of_children = new_entry.reservation_number_of_children AND
                start_date = new_entry.reservation_start_date AND
                end_date = new_entry.reservation_end_date
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION validate_e_mail (e_mail varchar)
RETURNS bool
AS $$
    import re
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.match(pattern, e_mail)) is not None
$$ LANGUAGE plpython3u;