#!/bin/bash

# Run on local machine
# export KUBECONFIG=~/.kube/config_file
# kubectl forward 10.1.2.3 5000:5432
# ./sync_db_credentials_from_k8s_secrets.sh DB_ENDPOINT DB_PORT DB_USER DB_PASS K8S_CONFIG_PATH K8S_TARGET_NAMESPACE
# example: ./sync_db_credentials_from_k8s_secrets.sh localhost 5000 postgres admin1234 ~/.kube/config_file default

DB_ENDPOINT=$1
DB_PORT=$2
export PGUSER=$3
export PGPASSWORD=$4
export KUBECONFIG=$5
K8S_NAMESPACES=$6

source "${BASH_SOURCE%/*}/_utils.sh"

DB_LIST=($(kubectl get secret app-db-secret --namespace $K8S_NAMESPACES -o json | jq -r '.data | to_entries | .[] | .key + ": " + (.value | @base64d)' | awk -F ': ' '{ gsub("_","-",$1); print $1":"$2 }'))
for DB in ${DB_LIST[@]}; do
  DB_USER=$(echo $DB | cut -d ":" -f 1)
  DB_PASSWORD=$(echo $DB | cut -d ":" -f 2)
  set_user_password $DB_ENDPOINT $DB_PORT $DB_USER $DB_PASSWORD
done

unset PGUSER
unset PGPASSWORD
unset KUBECONFIG