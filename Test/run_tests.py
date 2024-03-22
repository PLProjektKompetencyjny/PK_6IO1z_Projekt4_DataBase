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
    2024-03-22      Stanisław Horna         Test type column added to the output table

"""

import os
import json
import psycopg2

from tabulate import tabulate

TESTS_DIR = "Test"
CONFIG_FILE_NAME = "Config.json"

# define DB credentials
DB_USER = "TN_admin"
DB_PASSWORD = "NestTravel"
DB_HOST = "127.0.0.1"
DB_PORT = "5432"
DB_DATABASE = "TravelNest"

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
    display_results(testResults, queries)
    
    return None

def get_queries_from_file() -> list[dict[str, str | bool]]:
    
    # build absolute path to config file
    ConfigFilePath = os.path.join(
        os.path.abspath(os.getcwd()),
        TESTS_DIR,
        CONFIG_FILE_NAME
    )
        
    result = []
    
    # read config
    with open(ConfigFilePath, 'r') as cfg:
        try:
            fileData = "\n".join(cfg.readlines())
        except:
            raise Exception(f"Cannot read config file in path {ConfigFilePath}")
        
        try:
            configuration = json.loads(fileData)
        except:
            raise Exception("Cannot read JSON config structure, might be corrupted")

    # loop through all configured tests
    for file_name in configuration["Tests"]:

        # build path to test file which will be read
        pathToRead = os.path.join(
            os.path.abspath(os.getcwd()),
            "Test",
            configuration["QueriesDirectory"],
            file_name
        )
        
        # check if query should end with success or fail
        if (file_name.split("/")[0]) == "Success":
            expectedResult = True
        else:
            expectedResult = False
        
        # extract test name
        testName = file_name.split("/")[1]
        
        # read query from file and append the output
        with open(pathToRead, 'r') as file:
            try:
                queryString = ("".join(file.readlines()))
            except:
                raise Exception(f"Cannot read query file in path {pathToRead}")
            
            result.append(
                {
                    "testName": testName,
                    "query": queryString,
                    "expectedResult": expectedResult
                }
            )

            
    return result

def query_postgres(queries) -> list[dict[str, str | bool]]:
    
    testResults = []
    
    # loop through configured queries
    for i in range(len(queries)):
        queryResult = None
        currentTestResult = {
            "Name": queries[i]["testName"],
            "Result": False,
            "Error": ""
        }

        try:
            # Connect to PostgreSQL database
            connection = psycopg2.connect(
                user=DB_USER,
                password=DB_PASSWORD,
                host=DB_HOST,  
                port=DB_PORT,        
                database=DB_DATABASE
            )

            # Execute the query
            cursor = connection.cursor()
            cursor.execute(queries[i]["query"])
            connection.commit()
            
            queryResult = True
            
        except Exception as error:
            
            # Assign error to result field
            queryResult = False
            currentTestResult["Error"] = error
        finally:
            
            # fill in appropriate test result
            if queryResult == queries[i]["expectedResult"]:
                currentTestResult["Result"] = True
            else:
                currentTestResult["Result"] = False
            
            # append current test result to result list
            testResults.append(currentTestResult)
            
            # close connection
            if connection:
                cursor.close()
                connection.close()

            
    return testResults


def display_results(testResults, queries):
    
    # set table headers
    dataHeaders = ["Test name", "Test type","Successful"]
    
    # set table data
    data = []
    
    for i in range(len(testResults)):
        if queries[i]["expectedResult"] == True:
            testType = "Success"
        else:
            testType = "Fail"
        data.append(
            [testResults[i]["Name"],testType, testResults[i]["Result"]]
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
        if test["Result"] != True:
            print(bcolors.FAIL + test["Name"] + bcolors.ENDC)
            print(test["Error"])
    
    return None

if __name__ == "__main__":
    main()