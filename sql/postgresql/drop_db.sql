-- kubectl forward abc.def.ap-southeast-1.rds.amazonaws.com 5432
-- psql -U USER_NAME -d DATABASE_NAME -a -f drop_db.sql -h localhost

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'db-name'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS "db-name";