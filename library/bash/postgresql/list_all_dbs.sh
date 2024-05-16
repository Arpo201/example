#!/bin/bash

DB_ENDPOINT=$SRC_PGHOST
source "${BASH_SOURCE%/*}/_utils.sh"

SQL_ALL_DB="SELECT datname FROM pg_database WHERE datistemplate = false and datname NOT IN ('postgres', 'rdsadmin')"

psql -h $DB_ENDPOINT --no-align -t -c "${SQL_ALL_DB}" | while read -a DB ; do
  echo $DB
done