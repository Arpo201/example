#!/bin/bash

SRC_DB_ENDPOINT=$SRC_PGHOST
DEST_DB_ENDPOINT=$DEST_PGHOST

source "${BASH_SOURCE%/*}/_utils.sh"

SQL_ALL_DB="SELECT datname FROM pg_database WHERE datistemplate = false and datname NOT IN ('postgres', 'rdsadmin')"

psql -h $SRC_DB_ENDPOINT --no-align -t -c "${SQL_ALL_DB}" | while read -a DB ; do

  echo Migrating $DB database

  drop_db $DB $DEST_DB_ENDPOINT
  create_db $DB $DEST_DB_ENDPOINT
  create_user $DB $DEST_DB_ENDPOINT
  add_user_privileges $DB $DEST_DB_ENDPOINT

  OUTPUT_FILE_PATH="$(dump_db $DB $SRC_DB_ENDPOINT | tail -n 1)"
  restore_db $DB $DEST_DB_ENDPOINT "$OUTPUT_FILE_PATH"

  vacuum_full_db $DB $DEST_DB_ENDPOINT
  analyze_db $DB $DEST_DB_ENDPOINT
  
  echo Migrate $DB database successfully
done