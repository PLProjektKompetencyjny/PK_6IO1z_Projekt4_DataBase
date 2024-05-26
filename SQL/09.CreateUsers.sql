/*
    .DESCRIPTION
        SQL script for PostgreSQL to CREATE backed users in TravelNest DB.

        Two users will be created:
            1. tn_api_read <- will have access to SELECT views only.

    .NOTES

        Version:            1.4
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      22-Mar-2024
        ChangeLog:

        Date            Who                     What
        2024-03-23      Stanisław Horna         add privileges for user management functions,
                                                UPDATES do not work without SELECT rights,
                                                to be investigated
        
        2024-04-30		Stanisław Horna			add privileges to service_view.

        2024-05-24      Stanisław Horna         remove api_read user.

        2024-05-26      Stanisław Horna         add privileges to check_room_availability, check_room_guest_number.
                                                add privileges to management views

*/

-- create required roles
CREATE ROLE "tn_api_write" LOGIN PASSWORD 'cba';

-- Grant privileges for WRITE user to operation views
GRANT CONNECT ON DATABASE "TravelNest" to "tn_api_write";
GRANT USAGE ON SCHEMA public TO "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON customer_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON invoice_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON reservation_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON room_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON user_view to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON service_view to "tn_api_write";

-- Grant privileges for WRITE user to management views
GRANT SELECT, INSERT, UPDATE ON service_mgmt to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON room_type_mgmt to "tn_api_write";
GRANT SELECT, INSERT, UPDATE ON room_mgmt to "tn_api_write";

-- Grant privileges for WRITE user to user functions
GRANT EXECUTE ON FUNCTION authenticate_user_account(varchar, varchar) to "tn_api_write";
GRANT EXECUTE ON FUNCTION insert_user_account(varchar, varchar, int) to "tn_api_write";
GRANT EXECUTE ON FUNCTION update_user_account_password(varchar, varchar, varchar, int) to "tn_api_write";


-- Grant privileges for WRITE user to utility functions
GRANT EXECUTE ON FUNCTION check_room_availability(int, timestamp, timestamp) to "tn_api_write";
GRANT EXECUTE ON FUNCTION check_room_guest_number(int, int) to "tn_api_write";