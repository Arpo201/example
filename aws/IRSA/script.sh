export KUBECONFIG=~/.kube/arpo
export AWS_PROFILE=dev03-admin
account_id=$(aws sts get-caller-identity --query "Account" --output text)
oidc_provider=$(aws eks describe-cluster --name arpo --region ap-southeast-1 --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
export namespace=default
export service_account=backup-postgres

aws iam create-role --role-name test-postgres-IRSA --assume-role-policy-document file://trust-relationship.json --description "my-role-description" --region ap-southeast-1
# aws iam delete-role --role-name test-postgres-IRSA

aws iam attach-role-policy --role-name test-postgres-IRSA --policy-arn=arn:aws:iam::<accountID>:policy/test-backup-posgrest

kubectl annotate serviceaccount -n default backup-postgres eks.amazonaws.com/role-arn=arn:aws:iam::<accountID>:role/test-postgres-IRSA

###### Confirm that the role and service account are configured correctly.
aws iam get-role --role-name test-postgres-IRSA --query Role.AssumeRolePolicyDocument
aws iam list-attached-role-policies --role-name test-postgres-IRSA


export policy_arn=arn:aws:iam::<accountID>:policy/test-backup-posgrest

kubectl describe serviceaccount backup-postgres -n default