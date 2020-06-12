#!/bin/bash
# set -e

# POSTGRES="psql --username ${POSTGRES_USER}"

# echo "Creating database: ${DB_NAME}"

# $POSTGRES <<EOSQL
# CREATE DATABASE ${DB_NAME} OWNER ${POSTGRES_USER};
# EOSQL

echo "Creating schema..."
psql -d wikidata -a -U inaki -f /schema.sql

echo "Populating database..."
psql -d ${POSTGRES_DB} -a  -U${POSTGRES_USER} -f /data.sql
