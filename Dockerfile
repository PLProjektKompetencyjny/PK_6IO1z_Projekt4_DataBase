FROM postgres:16.2

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