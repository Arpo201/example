#!/bin/bash
# kubectl forward PROJECT.ID.ap-southeast-1.rds.amazonaws.com 5000:5432

source "${BASH_SOURCE%/*}/_utils.sh"

SRC_PGPORT=5000
SRC_PGPASSWORD=""
DEST_PGPORT=6000
DEST_PGPASSWORD=""
OUTPUT_DIR="${BASH_SOURCE%/*}/outputs"

rm -rf outputs
mkdir -p outputs


TARGET_DBS=("DB_1" "DB_2")

for db in "${TARGET_DBS[@]}"; do
(
  full_vacuum_db $SRC_PGPORT $SRC_PGPASSWORD $db
  dump_db $SRC_PGPORT $SRC_PGPASSWORD $db $OUTPUT_DIR

  drop_db $DEST_PGPORT $DEST_PGPASSWORD $db
  create_db $DEST_PGPORT $DEST_PGPASSWORD $db
  allow_privileges_db $DEST_PGPORT $DEST_PGPASSWORD $db

  restore_db $DEST_PGPORT $DEST_PGPASSWORD $db $OUTPUT_DIR
  analyze_db $DEST_PGPORT $DEST_PGPASSWORD $db
) &
done

wait