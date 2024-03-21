#!/bin/sh

### DESCRIPTION
# Script to build fresh image of PostgreSQL with init files to build TravelNest DB,
# run docker container and run configured tests on DataBase.

### INPUTS
# None

### OUTPUTS
#  1.  Docker build image
# (2). Docker logs if docker run failed
#  3.  DB test results

### EXIT CODES
# 0 - Success
# 1 - Docker daemon is not running
# 2 - Image build failed
# 3 - Container did not start correctly


### CHANGE LOG
# Author:   Stanisław Horna
# GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
# Created:  21-Mar-2024
# Version:  1.0

# Date            Who                     What

# define echo colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

# define docker variables
DockerImageName="postgres"
DockerContainerName="postgreSQL"
HostPortToOpen="5432"

# define tests vars
TestRunFilePath="./Test/run_tests.py"

Main() {

    # check if docker is running
    if docker ps -a -q -f name="Certainly Not Exist"; then
        printGreenMessage "Docker daemon is running"
    else
        printRedMessage "Docker daemon is not running"
        exit 1
    fi

    # check if postgreSQL container is running, if yes remove it.
    if [ -n "$(docker ps -a -q -f name="$DockerContainerName")" ]; then
        docker rm -f -v $DockerContainerName
        printGreenMessage "Old Container removed"
    else
        printYellowMessage "Container was not running"
    fi

    # build new image for DB container
    if docker build -t $DockerImageName .; then
        printGreenMessage "Image build successful"
    else
        printRedMessage "Image build failed"

        exit 2
    fi

    # run container based on the new docker image
    docker run --name $DockerContainerName -p $HostPortToOpen:5432 -d $DockerImageName

    # invoke sleep to wait for full initialization of the database
    sleep 2

    # check if container is still running, 
    #   if not display container logs.
    #   if yes invoke DB tests.
    #
    # if there were some error during initialization container will not be running
    if [ -z "$(docker ps -q -f name="$DockerContainerName")" ]; then
        docker logs $DockerContainerName

        printRedMessage "Container is not running"
        exit 3
    else
        printGreenMessage "Container is running"
        runDBtests
    fi
}

runDBtests(){
    printYellowMessage "Running tests"
    python3 $TestRunFilePath
    echo ""
}

printGreenMessage() {
    Message=$1
    echo ""
    echo "${GREEN}$Message${RESET}"
    echo ""
}

printRedMessage() {
    Message=$1
    echo ""
    echo "${RED}$Message${RESET}"
    echo ""
}

printYellowMessage() {
    Message=$1
    echo ""
    echo "${YELLOW}$Message${RESET}"
    echo ""
}

Main
