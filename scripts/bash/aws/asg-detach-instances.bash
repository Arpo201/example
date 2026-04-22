#!/bin/bash
set -e

if [ -z "$AWS_PROFILE" ]; then
  echo "AWS_PROFILE is missing"
  exit 1
fi

ASG_DECREASE_POLICY=""

POLICIES=("same-node-number" "decrease-node-number")
echo -e "\nSelect decreament policy"
select POLICY in ${POLICIES[@]}; do
  case $POLICY in
    ${POLICIES[0]})
      ASG_DECREASE_POLICY="--no-should-decrement-desired-capacity"
      ;;
    ${POLICIES[1]})
      ASG_DECREASE_POLICY="--should-decrement-desired-capacity"
      ;;
    *)
        echo "Invalid policy"
        exit 1
      ;;
    esac
  break
done

ASG_NAME_LIST=$(aws autoscaling describe-auto-scaling-groups --output json | jq -r '.AutoScalingGroups[].AutoScalingGroupName')
echo -e "\nSelect autoscaling group name"
select ASG_NAME in $ASG_NAME_LIST; do
  read -p "Detach all instances in $ASG_NAME with \`$ASG_DECREASE_POLICY\` flag (y/n)? " CONDITION
  if [ "$CONDITION" != "y" ]; then
    exit 1
  fi
  ASG_INSTANCES_IDS=$(aws autoscaling describe-auto-scaling-instances --query AutoScalingInstances[?AutoScalingGroupName==\`$ASG_NAME\`].InstanceId --output text --no-cli-pager)
  echo "$ASG_INSTANCES_IDS"
  aws autoscaling detach-instances \
        --output text \
        --no-should-decrement-desired-capacity \
        --auto-scaling-group-name $ASG_NAME \
        --instance-ids $ASG_INSTANCES_IDS
  echo "Detatch complete: $ASG_INSTANCES_IDS"
  break
done
