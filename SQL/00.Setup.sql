/*
    .DESCRIPTION
        SQL script for PostgreSQL to execute any setup instructions in TravelNest DB,
        like adding extensions etc.


    .NOTES

        Version:            1.1
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      18-Mar-2024
        ChangeLog:

        Date            Who                     What
        2024-04-20      Stanisław Horna         Add pg_stat_statements extension.
*/

CREATE EXTENSION plpython3u;

CREATE EXTENSION pg_stat_statements;

CREATE EXTENSION system_stats;