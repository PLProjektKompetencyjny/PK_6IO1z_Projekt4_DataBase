/*
    .DESCRIPTION
        SQL script for PostgreSQL to CREATE backed users in TravelNest DB.

        Two users will be created:
            1. tn_api_read <- will have access to SELECT views only.
            2. tn_api_write <- will have access to INSERT and UPDATE views only.

    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      22-Mar-2024
        ChangeLog:

        Date            Who                     What

*/

-- create required roles
CREATE ROLE "tn_api_read" LOGIN PASSWORD 'abc';
CREATE ROLE "tn_api_write" LOGIN PASSWORD 'cba';


-- Grant privileges for READ user
GRANT CONNECT ON DATABASE "TravelNest" to "tn_api_read";
GRANT USAGE ON SCHEMA public TO "tn_api_read";
GRANT SELECT ON customer_view to "tn_api_read";
GRANT SELECT ON invoice_view to "tn_api_read";
GRANT SELECT ON reservation_view to "tn_api_read";
GRANT SELECT ON room_view to "tn_api_read";
GRANT SELECT ON user_view to "tn_api_read";


-- Grant privileges for WRITE user
GRANT CONNECT ON DATABASE "TravelNest" to "tn_api_write";
GRANT USAGE ON SCHEMA public TO "tn_api_write";
GRANT INSERT, UPDATE ON customer_view to "tn_api_write";
GRANT INSERT, UPDATE ON invoice_view to "tn_api_write";
GRANT INSERT, UPDATE ON reservation_view to "tn_api_write";
GRANT INSERT, UPDATE ON room_view to "tn_api_write";
GRANT INSERT, UPDATE ON user_view to "tn_api_write";