SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'current_db'
  AND pid <> pg_backend_pid();

ALTER DATABASE "current_db" RENAME TO "new_db";

ALTER USER "current_db" RENAME TO "new_db";