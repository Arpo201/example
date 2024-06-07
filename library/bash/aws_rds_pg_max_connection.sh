#!/bin/bash

# Get memory in GB from the first argument
mem_gb=$1

# Calculate memory in bytes
mem_bytes=$((mem_gb * 1024 * 1024 * 1024))

# RDS Max Memory
max_connections=$((mem_gb / 9531392))

echo "Max connection for postgresql : $max_connections"
