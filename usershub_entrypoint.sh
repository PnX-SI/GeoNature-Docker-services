#!/bin/bash

apt update && apt install netcat -y  

# Function to check if PostgreSQL is alive
function wait_for_postgres() {
  echo "Waiting for PostgreSQL to be available at ${POSTGRES_HOST}:${POSTGRES_PORT}..."

  until nc -z "${POSTGRES_HOST}" "${POSTGRES_PORT}"  ; do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 1
  done

  echo "PostgreSQL is up and running!"
}

wait_for_postgres

exec "$@"