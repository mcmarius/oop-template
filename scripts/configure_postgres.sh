#!/usr/bin/bash

# load password into the environment
export PGPASSWORD=$DATABASE_PASSWORD

while true; do
    # Check if the connection was successful
    if psql -h 127.0.0.1 -U "$DATABASE_USER" -d postgres -c "SELECT 1"; then
        echo "PostgreSQL is ready!"

        # create database
        psql -h 127.0.0.1 -U "$DATABASE_USER" -d postgres -c "CREATE DATABASE $DATABASE_NAME WITH OWNER $DATABASE_USER;"

        # add cryptography extension
        psql -h 127.0.0.1 -U "$DATABASE_USER" -d "$DATABASE_NAME" -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
        break
    else
        echo "PostgreSQL is not ready, retrying in 5 seconds..."
        sleep 5
    fi
done