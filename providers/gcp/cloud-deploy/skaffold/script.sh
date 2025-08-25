gcloud deploy apply --file 'clouddeploy.yaml' --project PROJECT_ID --region asia-southeast1

# https://cloud.google.com/deploy/docs/deploying-application?hl=en#invoke_your_delivery_pipeline_to_create_a_release
gcloud deploy releases create 'test-release-001' \
  --project=PROJECT_NAME \
  --region=asia-southeast1 \
  --delivery-pipeline=custom-targets-pipeline