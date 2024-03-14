# Build docker image
    docker build -t postgres .

# Run container
    docker run --name postgreSQL -p 5432:5432 -e POSTGRES_PASSWORD=test -d postgres

# [Functions in Python](https://www.postgresql.org/docs/current/plpython-funcs.html)