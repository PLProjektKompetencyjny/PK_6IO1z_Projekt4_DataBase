FROM postgres:16.2


#######################################################################################################################
############################################### Environmental variables ###############################################
#######################################################################################################################

### Container
ENV TZ="Europe/Warsaw"

### Database
ENV POSTGRES_DB="TravelNest"
ENV POSTGRES_PASSWORD="NestTravel"
ENV POSTGRES_USER="TN_admin"
#### Set DB collate
ENV POSTGRES_INITDB_ARGS="--encoding=UTF-8 --lc-collate=pl_PL.utf8 --lc-ctype=pl_PL.utf8"

#### DB extension
##### system_stats extension
# EXTENSION_SYSTEM_STATS_FILE - file name of the archive file located in SystemStats directory,
#    which includes necessary code to enable extension.
#
# EXTENSION_SYSTEM_STATS_WORKDIR - working directory location used to unpack the archive file
#    and store initialization script. This location will be flushed after extension init
ENV EXTENSION_SYSTEM_STATS_FILE="system_stats-2.1.tar.gz"
ENV EXTENSION_SYSTEM_STATS_WORKDIR="/tmp"

##### pg_stat_statements extension
# EXTENSION_PG_STAT_TRACKED_STATEMENTS -  maximum number of statements tracked by the module 
#    (i.e., the maximum number of rows in the pg_stat_statements view). 
#    If more distinct statements than that are observed, information about the least-executed statements is discarded. 
#    The number of times such information was discarded can be seen in the pg_stat_statements_info view. 
#    The default value is 5000.
# 
# EXTENSION_PG_STAT_COUNTED_STATEMENTS - controls which statements are counted by the module. 
#    Specify top to track top-level statements (those issued directly by clients), all to also track nested statements 
#    (such as statements invoked within functions), or none to disable statement statistics collection. 
#    The default value is top.
ENV EXTENSION_PG_STAT_TRACKED_STATEMENTS="10000"
ENV EXTENSION_PG_STAT_COUNTED_STATEMENTS="all"


#######################################################################################################################
################################################ Packages installation ################################################
#######################################################################################################################

# Install plpython extension for code written in Python support
RUN apt-get update
RUN apt-get install -y postgresql-plpython3-16
RUN apt-get install -y python3-pip
RUN apt-get install -y locales locales-all

# Install package to support top and free shell commands
RUN apt-get install -y procps 

# Install dependencies for system_stats extension
RUN apt-get install -y make
RUN apt-get install -y gcc
RUN apt-get install -y postgresql-server-dev-16


#######################################################################################################################
##################################################### Copy files ######################################################
#######################################################################################################################

# Copy scripts to run on startup
COPY ./SQL/* /docker-entrypoint-initdb.d/

# Copy archive with system_stats extension code and initialization script
COPY ./SystemStats/*  ${EXTENSION_SYSTEM_STATS_WORKDIR}/

# Copy python requirements file and install
COPY ./requirements.txt ./requirements.txt
RUN pip install -r requirements.txt --break-system-packages

#######################################################################################################################
########################################### Init system_stats dependencies ############################################
#######################################################################################################################

# Run system_stats initialization script
RUN chmod +x ${EXTENSION_SYSTEM_STATS_WORKDIR}/Configure_system_stats.sh
RUN ${EXTENSION_SYSTEM_STATS_WORKDIR}/Configure_system_stats.sh

# Cleanup temp directory
RUN rm -fr ${EXTENSION_SYSTEM_STATS_WORKDIR}/*


#######################################################################################################################
############################################## Start PostgreSQL engine ################################################
#######################################################################################################################

EXPOSE 5432
CMD ["postgres"]
