#!/bin/sh
### DESCRIPTION
# Script to set up PostgreSQL to use system_stats extension.
# It requires to unpack archive file, compile code and install it.

### INPUTS
# None

### OUTPUTS
# None

### CHANGE LOG
# Author:   Stanisław Horna
# GitHub Repository:  https://github.com/PLProjektKompetencyjny/PK_6IO1z_Projekt4_DataBase
# Created:  21-Apr-2024
# Version:  1.0

# Date            Who                     What
#

ArchiveFileName="system_stats-2.1.tar.gz"

Main(){
    cd "/tmp" || exit 1
    UnpackArchive
    CompileCode
    InstallCode
}

UnpackArchive(){
    tar -zxvf "./$ArchiveFileName" 
    directoryName="${ArchiveFileName%.*}"
    directoryName="${directoryName%.*}"
    cd "./$directoryName" || exit 1
}

CompileCode(){
    PATH="/usr/local/pgsql/bin:$PATH" make USE_PGXS=1
}

InstallCode(){
    PATH="/usr/local/pgsql/bin:$PATH" make install USE_PGXS=1
}

Main
