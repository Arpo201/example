#!/bin/bash

##################### Migrate data #####################
# ---------------------------------------------------

function dump_db {
  local DB=$1
  local DB_ENDPOINT=$2

  local OUTPUT_DIR="/tmp/backup"
  local OUTPUT_FILE="$OUTPUT_DIR/$DB.dump"
  rm -fr $OUTPUT_DIR
  mkdir -p $OUTPUT_DIR

  echo -e "Dumping $DB database \n"
  pg_dump -h $DB_ENDPOINT --no-owner -v -Fc $DB > $OUTPUT_FILE
  echo "$OUTPUT_FILE"
}

function restore_db {
  local DB=$1
  local DB_USER=$1
  local DB_ENDPOINT=$2
  local RESTORE_FILE_PATH=$3

  echo -e "Restoring $DB database \n"
  pg_restore -h $DB_ENDPOINT --no-owner -v --role=$DB_USER -d $DB $RESTORE_FILE_PATH
  echo "Restore $DB database completed"
}

# ---------------------------------------------------
#####################################################

##################### Manage DB #####################
# ---------------------------------------------------

function create_db {
  local DB=$1
  local DB_ENDPOINT=$2

  echo -e "Creating $DB database"
  createdb -h $DB_ENDPOINT $DB
  echo -e "Create $DB database completed"
}

function drop_db {
  local DB=$1
  local DB_ENDPOINT=$2

  echo -e "Droping $DB database"
  dropdb -h $DB_ENDPOINT --if-exists -f $DB
  echo -e "Drop $DB database completed"
}

function rename_db {
  local CURRENT_DB_NAME=$1
  local NEW_DB_NAME=$2
  local DB_ENDPOINT=$3

  local SQL="
    SELECT pg_terminate_backend(pg_stat_activity.pid)
    FROM pg_stat_activity
    WHERE pg_stat_activity.datname = '$CURRENT_DB_NAME'
      AND pid <> pg_backend_pid();

    ALTER DATABASE "$CURRENT_DB_NAME" RENAME TO "$NEW_DB_NAME";

    ALTER USER "$CURRENT_DB_NAME" RENAME TO "$NEW_DB_NAME";
  "

  echo -e "Renaming $DB database"
  echo -n $SQL > /tmp/rename_db.sql
  psql -h $DB_ENDPOINT -v ON_ERROR_STOP=0 -f /tmp/rename_db.sql
  echo -e "Rename $DB database completed"
}

# ---------------------------------------------------
#####################################################


#################### Manage user ####################
# ---------------------------------------------------

function create_user {
  local DB=$1
  local DB_ENDPOINT=$2

  echo -e "Creating $DB user"
  createuser -h $DB_ENDPOINT $DB
  echo -e "Create $DB user completed"
}

function set_user_password {
  local DB_ENDPOINT=$1
  local DB_PORT=$2
  local DB_USER=$3
  local DB_NEW_PASSWORD=$4

  echo -e "Setting $DB_USER user password"
  echo "$DB_USER => $DB_NEW_PASSWORD"
  psql -h $DB_ENDPOINT -p $DB_PORT -d $DB_USER -v ON_ERROR_STOP=0  << EOF
  ALTER ROLE "$DB_USER" WITH PASSWORD '$DB_NEW_PASSWORD'; 
EOF
  echo -e "Set $DB_USER user password completed \n"
}

function add_user_privileges {
  local DB=$1
  local DB_USER=$1

  local DB_ENDPOINT=$2
  
  echo -e "Allowing privileges for $DB database \n"

  psql -h $DB_ENDPOINT -v ON_ERROR_STOP=0 -d $DB << EOF
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
  GRANT ALL ON SCHEMA public TO "$DB_USER";
  GRANT ALL PRIVILEGES ON DATABASE "$DB" TO "$DB_USER";
EOF
  echo -e "Allow privileges for $DB database completed \n"
}

# ---------------------------------------------------
#####################################################


#################### Optimize DB ####################
# ---------------------------------------------------

function vacuum_full_db {
  local DB=$1
  local DB_ENDPOINT=$2

  echo -e "Vacuuming $DB database \n"
  psql -h $DB_ENDPOINT -d $DB -c "VACUUM FULL VERBOSE"
  echo -e "Vacuum $DB database completed \n"
}

function analyze_db {
  local DB=$1
  local DB_ENDPOINT=$2

  echo -e "Analyzing $DB database \n"
  psql -h $DB_ENDPOINT -d $DB -c "ANALYZE VERBOSE"
  echo -e "Analyze $DB database completed \n"
}

# ---------------------------------------------------
#####################################################


function test_function {
  echo "Hello from test function with '$@' arguments"
}