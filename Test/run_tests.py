"""
.DESCRIPTION
    Script to execute SQL queries on PostgreSQL DB hosted locally.
    It will read config file and execute each query in defined order.

.INPUTS
    None

.OUTPUTS
     1.   Table with result of each test.
    (2).  Error message for tests which ended differently than expected.

.NOTES

    Version:            1.1
    Author:             Stanisław Horna
    Mail:               stanislawhorna@outlook.com
    GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
    Creation Date:      21-Mar-2024
    ChangeLog:

    Date            Who                     What
    2024-03-22      Stanisław Horna         Test type column added to the output table.
                                            Verification if all test files are configured in Config.json
    
    2024-03-23      Stanisław Horna         Support for using different accounts.

"""

import os
import json
import psycopg2

from tabulate import tabulate

TESTS_DIR = "Test"
CONFIG_FILE_NAME = "Config.json"
SUCCESS_DIR = "Success"
FAIL_DIR = "Fail"

# define DB credentials
DB_HOST = "127.0.0.1"
DB_PORT = "5432"
DB_DATABASE = "TravelNest"
DB_PASSWORD = {
    "tn_api_read" : "abc",
    "tn_api_write" : "cba"
}

# define console text colors
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def main() -> None:

    queries = get_queries_from_file()
    testResults = query_postgres(queries)
    display_results(testResults)

    return None


def get_queries_from_file() -> list[dict[str, str | bool]]:

    # build absolute path to config file
    ConfigFilePath = os.path.join(
        os.path.abspath(os.getcwd()),
        TESTS_DIR,
        CONFIG_FILE_NAME
    )

    # read config
    with open(ConfigFilePath, 'r') as cfg:
        try:
            fileData = "\n".join(cfg.readlines())
        except:
            raise Exception(f"Cannot read config file in path {ConfigFilePath}")

        try:
            configuration = json.loads(fileData)
        except:
            raise Exception(
                "Cannot read JSON config structure, might be corrupted")

    checkIfAllExistingFilesAreConfigured(configuration)

    # loop through all configured tests
    for test in configuration["Tests"]:

        # build path to test file which will be read
        pathToRead = os.path.join(
            os.path.abspath(os.getcwd()),
            TESTS_DIR,
            configuration["QueriesDirectory"],
            test["ExpectedResult"],
            test["TestName"]
        )

        # check if query should end with success or fail
        if (test["ExpectedResult"]).lower() == "success":
            expectedResult = True
        else:
            expectedResult = False

        # read query from file and append the output
        with open(pathToRead, 'r') as file:
            try:
                queryString = ("".join(file.readlines()))
            except:
                raise Exception(f"Cannot read query file in path {pathToRead}")
            
            test["Query"] = queryString
            test["ExpectedResultBool"] = expectedResult
            
    return configuration["Tests"]


def checkIfAllExistingFilesAreConfigured(configuration) -> None:

    locationToCheck = {
        'Success': os.path.join(
            os.path.abspath(os.getcwd()),
            TESTS_DIR,
            configuration["QueriesDirectory"],
            SUCCESS_DIR
        ),
        'Fail': os.path.join(
            os.path.abspath(os.getcwd()),
            TESTS_DIR,
            configuration["QueriesDirectory"],
            FAIL_DIR
        )
    }

    configuredTests = {
        'Success': [testFile["TestName"] for testFile in configuration["Tests"] if testFile["ExpectedResult"] == "Success"],
        'Fail': [testFile["TestName"] for testFile in configuration["Tests"] if testFile["ExpectedResult"] == "Fail"]
        } 
    
    for type in locationToCheck:

        items = os.listdir(locationToCheck[type])
        for file in items:
            
            if file not in configuredTests[type]:
                print(bcolors.WARNING + file + " " + type + " test is not configured in config file" +bcolors.ENDC)
                
    return None


def query_postgres(queries) -> list[dict[str, str | bool]]:

    # loop through configured queries
    for test in queries:
        queryResult = None

        try:
            # Connect to PostgreSQL database
            connection = psycopg2.connect(
                user=test["Username"],
                password=DB_PASSWORD[(test["Username"])],
                host=DB_HOST,
                port=DB_PORT,
                database=DB_DATABASE
            )

            # Execute the query
            cursor = connection.cursor()
            cursor.execute(test["Query"])
            connection.commit()

            queryResult = True

        except Exception as error:

            # Assign error to result field
            queryResult = False
            test["Error"] = error
        finally:

            # fill in appropriate test result
            if queryResult == test["ExpectedResultBool"]:
                test["Success"] = True
            else:
                test["Success"] = False

            # close connection
            if connection:
                cursor.close()
                connection.close()

    return queries


def display_results(testResults):
    
    # set table headers
    dataHeaders = ["Test name", "Test type", "Successful"]

    # set table data
    data = []

    for i in range(len(testResults)):
        data.append(
            [testResults[i]["TestName"], testResults[i]["ExpectedResult"], testResults[i]["Success"]]
        )

    # print result table
    print()
    print(
        tabulate(
            headers=dataHeaders,
            tabular_data=data,
            tablefmt="github",
        )
    )
    print()

    # print errors for tests which ended different than expected
    for test in testResults:
        if test["Success"] != True:
            print(bcolors.FAIL + test["TestName"] + bcolors.ENDC)
            print(test["Error"])

    return None


if __name__ == "__main__":
    main()
