#!/usr/bin/env bash

TFENV="/usr/local/bin/tfenv"
TF_INIT_PATH="/app/terraform/scripts/tf_init.sh"

${TFENV} install 0.11.7
${TFENV} use 0.11.7

# Build TF Statefile s3 bucket
# TODO test if exists
echo "entering /app/terraform/src/00-init"
cd /app/terraform/src/00-init

echo "running ${TF_INIT_PATH}"
${TF_INIT_PATH}

#####
terraform plan
#####

# Build VPC
echo "entering /app/terraform/src/01-vpc"
cd /app/terraform/src/01-vpc

echo "running ${TF_INIT_PATH}"
${TF_INIT_PATH}

#####
terraform plan
#####

# Deploy ECS Jenkins
echo "entering /app/terraform/src/02-main"
cd /app/terraform/src/02-main

echo "running ${TF_INIT_PATH}"
${TF_INIT_PATH}

#####
terraform plan
#####
