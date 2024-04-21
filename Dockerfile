FROM postgres:16.2

# Install plpython extension for code written in Python support
RUN apt-get update
RUN apt-get install -y postgresql-plpython3-16
RUN apt-get install -y locales locales-all

# Install package to support top and free shell commands
RUN apt-get install -y procps 

# Install dependencies for system_stats extension
RUN apt-get install -y make
RUN apt-get install -y gcc
RUN apt-get install -y postgresql-server-dev-16

# Set timezone
ENV TZ="Europe/Warsaw"
RUN date

# Set DB name and default user
ENV POSTGRES_DB="TravelNest"
ENV POSTGRES_PASSWORD="NestTravel"
ENV POSTGRES_USER="TN_admin"

# Set DB collate
ENV POSTGRES_INITDB_ARGS="--encoding=UTF-8 --lc-collate=pl_PL.utf8 --lc-ctype=pl_PL.utf8"

# Copy scripts to run on startup
COPY ./SQL/* /docker-entrypoint-initdb.d/

# Copy archive with system_stats extension code and initialization script
COPY ./SystemStats/system_stats-2.1.tar.gz  /tmp/
COPY ./SystemStats/Configure_system_stats.sh /tmp/

# Run system_stats initialization script
RUN chmod +x /tmp/Configure_system_stats.sh
RUN /tmp/Configure_system_stats.sh

# Cleanup temp directory
RUN rm -fr /tmp/*

EXPOSE 5432
CMD ["postgres"]
