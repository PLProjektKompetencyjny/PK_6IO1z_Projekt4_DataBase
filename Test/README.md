# DB Testing
The purpose of this module is to test different scenarios which Backend DB user might perform, in order to verify if the logic implemented directly in the DataBase is correct.

    Test
     ├── Config.json
     ├── run_tests.py
     ├── TestQueries
     │   ├── Fail
     │   └── Success
     └── README.md

In folder `TestQueries/Success` save queries which should not result in any errors. 

In folder `TestQueries/Fail` save queries which should throw an error.

Each query file should contain only 1 statement with, structure of such file should look like below:
    
    /*
        Test query to create invoices for reservation number 2 and 3 in bulk
        Expected result: success
    */

    INSERT INTO invoice_view (invoice_reservation_id)
    VALUES
    (2),
    (3);

File should be saved in following name format: `<view_name>_<INSTRUCTION>_<descriptive_title>`

Once query file is saved in proper location go to `Config.json` and add your query in a appropriate order to other queries. Script is executing them from top to the bottom.
Entry line should look like: `<Success_or_Fail>/<created_file_name>`

