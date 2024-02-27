pipeline_name=$0
gcs_url=$1

gcloud deploy releases create 'release-$DATE-$TIME' \
  --project=PROJECT \
  --region=asia-southeast1 \
  --delivery-pipeline=$pipeline_name \
  --gcs-source-staging-dir="$gcs_url/pre-render" \
