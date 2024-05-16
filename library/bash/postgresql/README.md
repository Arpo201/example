# Requrie environments
- SRC_PGHOST
- DEST_PGHOST
- PGUSER
- PGPASSWORD
- (Optional) PGPORT

# Usage

- `migrate_all_dbs.sh` จะ migrate ทุก database จาก SRC_PGHOST -> DEST_PGHOST

- `migrate_target_dbs.sh` จะ migrate ตาม db_names arguments ที่ใส่ไป ตัวอย่าง
  ```#!/bin/bash
  ./migrate_target_dbs.sh db-dev db-qa db-accounts
  ```
## Copy scripts to pod
```#!/bin/bash
cd scripts && kubectl cp . <pod-name>:/root
```

## Migrate only target databases
```#!/bin/bash
./test.sh test-db-1 test-db-2
```


## Call function in shell script
```#!/bin/bash
. ./_utils.sh && test_function db_1 db_2
```

## EC2
config path: `/etc/postgresql/15/main/postgresql.conf`
```#!/bin/bash
export AWS_PROFILE=dev04-admin
aws ssm start-session --target i-0f46eb261ec1535a7
```