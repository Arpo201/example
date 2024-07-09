#!/bin/bash

set -e

# Usage: 
## 1) export KUBECONFIG=~/.kube/config_file
## 2) kubectl forward <DB_SERVER_ENDPOINT> 6000:5432
## 3) Config variables such as PGUSER, PGPASSWORD, SRC_DB_ENDPOINT, etc
## 4) ./migrate_target_dbs.sh DB1 DB2 DB3

source "${BASH_SOURCE%/*}/_utils.sh"

TARGET_DBS=("$@")
export PGUSER="postgres"
export PGPASSWORD=""

SRC_DB_ENDPOINT=localhost
SRC_PORT=5000

DEST_DB_ENDPOINT=localhost
DEST_PORT=6000

mkdir -p /tmp/backup/logs

for DB in "${TARGET_DBS[@]}"; do
  (
    echo -e "Migrating $DB database\n"

    create_db $DB $DEST_DB_ENDPOINT $DEST_PORT
    create_user $DB $DEST_DB_ENDPOINT $DEST_PORT
    add_user_privileges $DB $DEST_DB_ENDPOINT $DEST_PORT

    dump_db $DB $SRC_DB_ENDPOINT $SRC_PORT
    restore_db $DB $DEST_DB_ENDPOINT $DEST_PORT "/tmp/backup/$DB.dump"

    vacuum_full_db $DB $DEST_DB_ENDPOINT $DEST_PORT
    analyze_db $DB $DEST_DB_ENDPOINT $DEST_PORT
    
    echo -e "Migrate $DB database successfully\n"
  ) 2>&1 | tee /tmp/backup/logs/$DB.log &
done

unset PGUSER
unset PGPASSWORD