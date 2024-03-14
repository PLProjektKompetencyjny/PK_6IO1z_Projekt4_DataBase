FROM postgres:latest

# Set polish language
RUN localedef -i pl_PL -c -f UTF-8 -A /usr/share/locale/locale.alias pl_PL.UTF-8
ENV LANG pl_PL.utf8

# Set timezone
ENV TZ="Europe/Warsow"
RUN date

# Copy scripts to run on startup
COPY ./SQL/* /docker-entrypoint-initdb.d/

EXPOSE 5432
CMD ["postgres"]