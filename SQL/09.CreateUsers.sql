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
        2024-03-23      Stanisław Horna         add privileges for user management functions,
                                                UPDATES do not work without SELECT rights,
                                                to be investigated

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
GRANT SELECT, INSERT, UPDATE ON customer_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON invoice_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON reservation_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON room_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON user_view to "tn_api_write";

GRANT EXECUTE ON FUNCTION authenticate_user_account(varchar, varchar) to "tn_api_write";
GRANT EXECUTE ON FUNCTION insert_user_account(varchar, varchar, int) to "tn_api_write";
GRANT EXECUTE ON FUNCTION update_user_account_password(varchar, varchar, varchar, int) to "tn_api_write";