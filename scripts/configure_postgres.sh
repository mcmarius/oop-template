#!/usr/bin/bash

# load password into the environment
export PGPASSWORD=$DATABASE_PASSWORD

# create database
psql -h 127.0.0.1 -U $DATABASE_USER -d postgres -c "CREATE DATABASE $DATABASE_NAME WITH OWNER $DATABASE_USER;"

# add cryptography extension
psql -h 127.0.0.1 -U $DATABASE_USER -d $DATABASE_NAME -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"