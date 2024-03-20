/*
    .DESCRIPTION
        SQL script for PostgreSQL to DROP default DB 'postgres', 
        which creation can not be skipped during container initialization.


    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      18-Mar-2024
        ChangeLog:

        Date            Who                     What

*/

DROP DATABASE IF EXISTS postgres;