#!/usr/bin/env bash

# AWS ROLE ARN
# AWS subaccount 301496033642 delius-new-tech-non-prod
export TERRAGRUNT_IAM_ROLE="arn:aws:iam::301496033642:role/terraform"

## GENERIC VARIABLES

# AWS-REGION
export TG_REGION="eu-west-2"

# BUSINESS_UNIT
export TG_BUSINESS_UNIT="hmpps"

# PROJECT
export TG_PROJECT="delius-new-tech"

# ENVIRONMENT
export TG_ENVIRONMENT_TYPE="dev"

## TERRAGUNT VARIABLES

export TG_ENVIRONMENT_IDENTIFIER="tf-${TG_REGION}-hmpps-${TG_PROJECT}-${TG_ENVIRONMENT_TYPE}"

# REMOTE_STATE_BUCKET
export TG_REMOTE_STATE_BUCKET="${TG_ENVIRONMENT_IDENTIFIER}-remote-state"

# ###################
# TERRAFORM VARIABLES
# ###################

export TF_VAR_environment_type=${TG_ENVIRONMENT_TYPE}
export TF_VAR_region=${TG_REGION}
export TF_VAR_remote_state_bucket_name=${TG_REMOTE_STATE_BUCKET}
