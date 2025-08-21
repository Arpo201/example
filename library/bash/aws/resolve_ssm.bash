#!/bin/bash
# This script resolves AWS SSM parameters from a pre-defined environment file
# Usage: ./resolve_ssm.bash pre-env.txt .env

# pre-env.txt example content:
## TEST1=arn:aws:ssm:ap-southeast-7:111111111111:parameter/my-parameter-1
## TEST2=arn:aws:ssm:ap-southeast-7:111111111111:parameter/my-parameter-2

# .env file example content:
## export TEST1=value1
## export TEST2=value2

# Use .env file command: source .env

if [ -z "$1" ]; then
  echo "Usage: $0 <input_file> <output_file>"
  exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE=$2

for line in $(cat pre-env.txt); do
  echo "Resolving $line"

  ENV_KEY=$(echo "$line" | cut -d'=' -f1)
  AWS_SSM_ARN=$(echo "$line" | cut -d'=' -f2)
  AWS_REGION=$(echo "$AWS_SSM_ARN" | cut -d':' -f4)

  echo "export $ENV_KEY=$(aws ssm get-parameter --region $AWS_REGION --name "$AWS_SSM_ARN" --with-decryption --query 'Parameter.Value' --output text)" >> $OUTPUT_FILE
done
