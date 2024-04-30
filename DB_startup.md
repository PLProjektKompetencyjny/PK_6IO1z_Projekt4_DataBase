# Automated way
## Add execute rights to shell script
    chmod +x ./rebuild.sh

## Run the script
    ./rebuild.sh

# Manual way
## Build docker image
    docker build -t postgres .

## Run container
    docker run --name postgreSQL -p 5432:5432 -d postgres
