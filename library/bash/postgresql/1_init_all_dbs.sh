#!/bin/bash

SRC_DB_ENDPOINT=$SRC_PGHOST
DEST_DB_ENDPOINT=$DEST_PGHOST

source "${BASH_SOURCE%/*}/_utils.sh"

SQL_ALL_DB="SELECT datname FROM pg_database WHERE datistemplate = false and datname NOT IN ('postgres', 'rdsadmin')"

psql -h $SRC_DB_ENDPOINT --no-align -t -c "${SQL_ALL_DB}" | while read -a DB ; do
  # drop_db $DB $DEST_DB_ENDPOINT
  create_db $DB $DEST_DB_ENDPOINT
  create_user $DB $DEST_DB_ENDPOINT
  add_user_privileges $DB $DEST_DB_ENDPOINT
done