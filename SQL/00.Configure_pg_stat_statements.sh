#!/usr/bin/env bash
### DESCRIPTION
# Script to set up PostgreSQL config file in order to support pg_stat_statements.
# It should be invoked automatically during PostgreSQL container startup.

### INPUTS
# MaxTrackedStatements -  maximum number of statements tracked by the module 
#    (i.e., the maximum number of rows in the pg_stat_statements view). 
#    If more distinct statements than that are observed, information about the least-executed statements is discarded. 
#    The number of times such information was discarded can be seen in the pg_stat_statements_info view. 
#    The default value is 5000.
# 
# CountedStatements - controls which statements are counted by the module. 
#    Specify top to track top-level statements (those issued directly by clients), all to also track nested statements 
#    (such as statements invoked within functions), or none to disable statement statistics collection. 
#    The default value is top.

### OUTPUTS
# None

### CHANGE LOG
# Author:   Stanisław Horna
# GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
# Created:  20-Apr-2024
# Version:  1.0

# Date            Who                     What
#

MaxTrackedStatements="10000"
CountedStatements="all"

Main() {
    {
        echo "shared_preload_libraries = 'pg_stat_statements'"
        echo "pg_stat_statements.max = $MaxTrackedStatements"
        echo "pg_stat_statements.track = $CountedStatements"
    } >> "$PGDATA/postgresql.conf"
}


Main
