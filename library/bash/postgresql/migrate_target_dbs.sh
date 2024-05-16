#!/bin/bash

source "${BASH_SOURCE%/*}/_utils.sh"

SRC_DB_ENDPOINT=$SRC_PGHOST
DEST_DB_ENDPOINT=$DEST_PGHOST
TARGET_DBS=("$@")

for DB in "${TARGET_DBS[@]}"; do

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
