#!/bin/bash

# Run on local machine
# export KUBECONFIG=~/.kube/kubeconfig_file
# kubectl forward x.x.x.x 5000:5432

# ./migrate_all_users_password.sh DB_ENDPOINT DB_PORT DB_USER DB_PASS K8S_CONFIG_PATH K8S_TARGET_NAMESPACE
# example: ./migrate_all_users_password.sh localhost 5000 postgres P@ssword ~/.kube/kubeconfig_file default

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