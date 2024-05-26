/*
    .DESCRIPTION
        SQL script for PostgreSQL to define sub functions in TravelNest DB.
        EXISTING FUNCTIONS WILL BE REMOVED AND RE-CREATED WITH THIS FILES' DEFINITION.

        This file is supposed to define all sub functions (related to user passwords),
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

        Version:            1.0
        Author:             Stanisław Horna
        Mail:               stanislawhorna@outlook.com
        GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
        Creation Date:      26-May-2024
        ChangeLog:

        Date            Who                     What

*/

CREATE OR REPLACE FUNCTION get_hash(phrase_to_hash varchar) 
RETURNS varchar
AS $$

    import bcrypt
    
    salt = bcrypt.gensalt()

    hashed_phrase = bcrypt.hashpw(phrase_to_hash.encode('utf-8'), salt)

    hashed_phrase_str = hashed_phrase.decode('utf-8')

    return hashed_phrase_str

$$ LANGUAGE plpython3u SECURITY DEFINER;

CREATE OR REPLACE FUNCTION compare_hashes(external_phrase varchar, hash_from_db varchar) 
RETURNS boolean
AS $$

    import bcrypt

    db_hash_value = hash_from_db.encode('utf-8')

    return bcrypt.checkpw(external_phrase.encode('utf-8'), db_hash_value)

$$ LANGUAGE plpython3u SECURITY DEFINER;