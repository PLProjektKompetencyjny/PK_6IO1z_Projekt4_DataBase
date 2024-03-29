/*
    .DESCRIPTION
        SQL script for PostgreSQL to define VIEW TRIGGERS in TravelNest DB.
        EXISTING TRIGGERS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is suposed to define all triggers to call functions:
            - INSTEAD OF INSERT
            - INSTEAD OF UPDATE
            - INSTEAD OF DELETE

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all triggers from scratch


    .RULES
		- Views have dedicated catalog for triggers, names must be:
            - ioi <- INSTEAD OF INSERT
            - iou <- INSTEAD OF UPDATE
            - iod <- INSTEAD OF DELETE 

		- TRIGGERS must be added in format: 
            CREATE OR REPLACE TRIGGER <trigger_name>
            INSTEAD OF INSERT ON <view_name>
            FOR EACH ROW
            EXECUTE FUNCTION <function_name>;


    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      20-Mar-2024
        ChangeLog:

        Date            Who                     What

*/

-- INSTEAD OF INSERT triggers



-- INSTEAD OF UPDATE triggers



-- INSTEAD OF DELETE triggers