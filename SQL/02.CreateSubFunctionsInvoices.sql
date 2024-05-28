/*
    .DESCRIPTION
        SQL script for PostgreSQL to define sub functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is supposed to define all sub functions (related to invoices),
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
        Creation Date:      25-May-2024
        ChangeLog:

        Date            Who                     What
        2024-05-28      Stanisław Horna         include services in invoice price gross.

*/

CREATE OR REPLACE FUNCTION calculate_invoice_price(reservation_to_calc_id int) 
RETURNS void 
AS $$
DECLARE
    Room_Price float;
    Service_Price float;
BEGIN

    SELECT
        SUM(RESERVATION_ROOM_PRICE_GROSS)
    INTO Room_Price
    FROM
        RESERVATION_ROOM
    WHERE
        RESERVATION_ID = reservation_to_calc_id;

    SELECT
        SUM(S.UNIT_PRICE * RS.QUANTITY)
    INTO Service_Price
    FROM
        RESERVATION_SERVICE RS
        LEFT JOIN SERVICE S ON S.ID = RS.SERVICE_ID
    WHERE
        RESERVATION_ID = reservation_to_calc_id;

    UPDATE INVOICE
    SET
        PRICE_GROSS = Room_Price + Service_Price
    WHERE
        RESERVATION_ID = reservation_to_calc_id;

    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;