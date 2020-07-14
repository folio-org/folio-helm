#!/bin/sh
echo Started at : $(date)
echo Preparing Databse
export PGPASSWORD=$DB_PASSWORD

psql -h $DB_HOST -d $DB_DATABASE -U $DB_USERNAME -a -q -f ./insert_deployments.sql

echo Completed at : $(date)
echo Please restart all OKAPI instances to reload the list of deployments.
