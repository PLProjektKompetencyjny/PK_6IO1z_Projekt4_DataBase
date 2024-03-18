/*
    .DESCRIPTION
        SQL script for PostgreSQL to define CHECK functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is suposed to define all check functions,
        which will be used in tables definition of CHECK CONSTRAINT.

		Following actions will be performed in a given order:
			1. CREATE OR REPLACE all functions from scratch


    .RULES
		- Names consisted of more than 1 word must use '_' as words separator.
			Object names such as tables, constraints, functions are not case sensitive,
			so to make them easy easy-readable please use word separator.

        - Check function must have a prefix 'check_' in the name. 
            Beacause all functions are located in the common Object explorer directory

        - Check function must return True or False values only. Try to avoid raising any exceptions.
            In order to prevent handling any CHECK related exceptions in INSERT / UPDATE statements

        - Check function can be written in SQL or PL/Python, both languages are supported,
            however if a Python one requires some additional packages to import,
            it would require to update Dockerfile.


    .NOTES

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      18-Mar-2024
        ChangeLog:

        Date            Who                     What

*/
