redis-cli -a $REDIS_PASSWORD SAVE

redis-cli -a $REDIS_PASSWORD info # Should be -> rdb_bgsave_in_progress:0

kubectl cp redis-master-0:/data/dump.rdb -n NAMESPACE dump.rdb

kubectl cp dump.rdb redis-master-0:/data/dump.rdb -n NAMESPACE  

redis-cli -a $REDIS_PASSWORD Shutdown ### reload 

# Redis will automatic read dump.rdb from /data
## Read priority: 1 appendonly.aof | 2 dump.rdb
## Delete appendonly.aof first if already exists