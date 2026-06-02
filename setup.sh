#!/bin/bash
# setup.sh — Recreates the doom_db schema and loads sample data

DB_NAME="doom_db"
DB_USER="postgres"

echo "Creating database..."
psql -U $DB_USER -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;"

echo "Running schema DDL..."
psql -U $DB_USER -d $DB_NAME -f sql/01_schema.sql

echo "Creating indexes..."
psql -U $DB_USER -d $DB_NAME -f sql/02_indexes.sql

echo "Creating views..."
psql -U $DB_USER -d $DB_NAME -f sql/03_views.sql

echo "Generating synthetic data..."
python etl/generate_data.py

echo "Loading data via ETL..."
psql -U $DB_USER -d $DB_NAME -c "\COPY stg_telemetry FROM 'etl/sample_telemetry.tsv' DELIMITER E'\t' CSV HEADER;"
psql -U $DB_USER -d $DB_NAME -f sql/05_etl.sql

echo "Done. Database $DB_NAME is ready."