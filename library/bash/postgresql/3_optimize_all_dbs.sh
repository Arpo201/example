#!/bin/bash

SRC_DB_ENDPOINT=$SRC_PGHOST
DEST_DB_ENDPOINT=$DEST_PGHOST

source "${BASH_SOURCE%/*}/_utils.sh"

SQL_ALL_DB="SELECT datname FROM pg_database WHERE datistemplate = false and datname NOT IN ('postgres', 'rdsadmin')"

psql -h $SRC_DB_ENDPOINT --no-align -t -c "${SQL_ALL_DB}" | while read -a DB ; do
  vacuum_full_db $DB $DEST_DB_ENDPOINT
  analyze_db $DB $DEST_DB_ENDPOINT
done
