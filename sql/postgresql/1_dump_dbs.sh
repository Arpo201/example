#!/bin/bash

export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
export PGPASSWORD=

target=("DB_NAME_A" "DB_NAME_B" "DB_NAME_C")

for db in "${target[@]}"
do
  echo "Dumping $db database"
  pg_dump --no-owner -Fc $db > $PWD/$db.dump
  echo "Output: $PWD/$db.dump"
done
