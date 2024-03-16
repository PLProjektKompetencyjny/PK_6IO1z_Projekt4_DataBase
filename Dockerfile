FROM postgres:16.2

# Set polish language
RUN localedef -i pl_PL -c -f UTF-8 -A /usr/share/locale/locale.alias pl_PL.UTF-8
ENV LANG pl_PL.utf8

# Set timezone
ENV TZ="Europe/Warsaw"
RUN date

# Set DB name and default user
ENV POSTGRES_DB="TravelNest"
ENV POSTGRES_PASSWORD="abc"
ENV POSTGRES_USER="TN_admin"

# Install plpython extension for code written in Python support
RUN apt-get update
RUN apt-get install -y postgresql-plpython3-16

# Copy scripts to run on startup
COPY ./SQL/* /docker-entrypoint-initdb.d/

EXPOSE 5432
CMD ["postgres"]