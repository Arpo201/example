#!/bin/bash

function check_required_env {
  local FUNCTION_NAME=$1
  echo "Current environments
  PGHOST: $PGHOST
  PGUSER: $PGUSER
  PGPORT: $PGPORT
  PGPASSWORD: $PGPASSWORD
  TARGET_DB: $TARGET_DB
  "

  if [[ -z $PGPORT ]]; then
    echo "PGPORT environment variables not exist"
  fi
  
  if [[ -z $PGPASSWORD ]]; then
    echo "PGPASSWORD environment variables not exist"
  fi
  
  if [[ -z $TARGET_DB ]]; then
    echo "TARGET_DB environment variables not exist"
  fi

  if [[ -z $PGPORT || -z $PGPASSWORD || -z $TARGET_DB ]]; then
    echo "example: $FUNCTION_NAME PORT PASSWORD TARGET_DB"
    exit 1 
  fi
}

function dump_db {
  export PGPORT=$1
  export PGPASSWORD=$2
  export TARGET_DB=$3
  export OUTPUT_DIR=$4
  
  export PGHOST=localhost
  export PGUSER=postgres

  check_required_env dump_db

  echo -e "Dumping $TARGET_DB database \n"
  pg_dump --no-owner -v -Fc $TARGET_DB > $OUTPUT_DIR/$TARGET_DB.dump
  echo "Output: $PWD/$TARGET_DB.dump"
}

function restore_db {
  export PGPORT=$1
  export PGPASSWORD=$2
  export TARGET_DB=$3
  export TARGET_ROLE=$3
  export SOURCE_DIR=$4
  
  export PGHOST=localhost
  export PGUSER=postgres

  check_required_env restore_db

  echo -e "Restoring $TARGET_DB database \n"
  pg_restore --no-owner -v --role=$TARGET_ROLE -d $TARGET_DB $SOURCE_DIR/$TARGET_DB.dump
  echo "Restore $TARGET_DB database completed"
}

function drop_db {
  export PGPORT=$1
  export PGPASSWORD=$2
  export TARGET_DB=$3

  export PGHOST=localhost
  export PGUSER=postgres

  echo -e "Droping $TARGET_DB database"
  dropdb -f $TARGET_DB
  echo -e "Drop $TARGET_DB database completed"
}

function create_db {
  export PGPORT=$1
  export PGPASSWORD=$2
  export TARGET_DB=$3

  export PGHOST=localhost
  export PGUSER=postgres

  echo -e "Creating $TARGET_DB database"
  createdb $TARGET_DB
  echo -e "Create $TARGET_DB database completed"
}

function full_vacuum_db {
  export PGPORT=$1
  export PGPASSWORD=$2
  export TARGET_DB=$3

  export PGHOST=localhost
  export PGUSER=postgres

  echo -e "Vacuuming $TARGET_DB database \n"
  psql -d $TARGET_DB -c "VACUUM FULL VERBOSE"
  echo -e "Vacuum $TARGET_DB database completed \n"

}

function analyze_db {
  export PGPORT=$1
  export PGPASSWORD=$2
  export TARGET_DB=$3

  export PGHOST=localhost
  export PGUSER=postgres

  echo -e "Analyzing $TARGET_DB database \n"
  psql -d $TARGET_DB -c "ANALYZE VERBOSE"
  echo -e "Analyze $TARGET_DB database completed \n"
}

function allow_privileges_db {
  export PGPORT=$1
  export PGPASSWORD=$2
  export TARGET_DB=$3
  export TARGET_ROLE=$3

  export PGHOST=localhost
  export PGUSER=postgres
  
  echo -e "Allowing privileges for $TARGET_DB database \n"

  psql -v ON_ERROR_STOP=0 -d $TARGET_DB << EOF
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
  GRANT ALL ON SCHEMA public TO "$TARGET_ROLE";
  GRANT ALL PRIVILEGES ON DATABASE "$TARGET_DB" TO "$TARGET_ROLE";
EOF
  echo -e "Allow privileges for $TARGET_DB database completed \n"
}
