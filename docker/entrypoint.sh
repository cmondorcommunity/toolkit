#!/usr/bin/env bash

set -x
set -e

[ -z "${ORG}" ] && {
    echo "################  ORG NOT SET   ##################"
}

[ -z "${PROJECT}" ] && {
    echo "################  PROJECT NOT SET   ##################"
}

[ -z "${ENVIRONMENT}" ] && {
    echo "################  ENVIRONMENT NOT SET   ##################"
}

[ -z "${DOMAIN}" ] && {
    echo "################  DOMAIN NOT SET   ##################"
}
S3_FINAL_BUCKET_NAME="${ORG}-tlkt-tfstate"
ECS_IMAGE_NAME="toolkit" #TODO get from .env
TF_VERSION="latest" # 0.11.7
TFENV="/usr/local/bin/tfenv"
TF_INIT_PATH="/app/terraform/scripts/tf_init.sh"
export HOME="/root"

${TFENV} install ${TF_VERSION}
${TFENV} use ${TF_VERSION}

[ ! -z "${DESTROY}" ] && {
    set +e
    cd /app/terraform/src/02-toolkit
    ${TF_INIT_PATH}
    terraform destroy
    cd /app/terraform/src/01-vpc
    ${TF_INIT_PATH}
    terraform destroy
    cd /app/terraform/src/00-init
    ${TF_INIT_PATH}
    terraform destroy
    set -e
    exit 0
}

cat << EOF

################################################################
Create Terraform Statefile s3 bucket /app/terraform/src/00-init
################################################################

EOF

# If terraform s3 statefile bucket exists, skip 00-init phase
aws s3 ls ${ORG}-tlkt-tfstate || {
    cd /app/terraform/src/00-init
    ${TF_INIT_PATH}
    terraform apply -var org=${ORG}
}

AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --query "Account" --output=text)

cat << EOF

###########################################
# Building VPC /app/terraform/src/01-vpc" #
#        and ECR Docker Registry          #
###########################################

EOF

cd /app/terraform/src/01-vpc
${TF_INIT_PATH}

terraform apply -var org=${ORG}
ECR_REPO_URL=$(echo "aws_ecr_repository.main.repository_url" | terraform console)

cat << EOF

###################################################
# Building/Publishing Jenkins Docker image to ECR #
###################################################

EOF

cd /app/jenkins
docker-compose build
REMOTE_IMAGE_URL="${ECR_REPO_URL}:latest"
docker tag ${ECS_IMAGE_NAME}  ${REMOTE_IMAGE_URL}
set +x
echo "Logging into ECR: aws ecr get-login"
$(aws ecr get-login --no-include-email)
set -x

[ -z "${TOOLKIT_SKIP_PUSH}" ] && {
    docker push ${REMOTE_IMAGE_URL}
}

# Deploy ECS Jenkins
cat << EOF

##############################################################
# Building ECS Jenkins Service /app/terraform/src/02-toolkit #
##############################################################

EOF

cd /app/terraform/src/02-toolkit
${TF_INIT_PATH}

terraform apply -var org=${ORG}

ELB_HOSTNAME=$(echo "aws_alb.main.dns_name" | terraform console)

# TODO readiness loop

cat << EOF

##################################################################################
# We'll need to wait for EC2 instances, ECS service and LB Healthchecks to pass. #
#                 Afterwhich, a Jenkins instance is available at                 #
#                                                                                #
#   http://${ELB_HOSTNAME}/
##################################################################################

EOF

