#!/usr/bin/env bash

set -x
set -e

ECS_IMAGE_NAME="toolkit" #TODO get from .env
TF_VERSION="latest" # 0.11.7
TFENV="/usr/local/bin/tfenv"
TF_INIT_PATH="/app/terraform/scripts/tf_init.sh"
export HOME="/root"

${TFENV} install ${TF_VERSION}
${TFENV} use ${TF_VERSION}

[ ! -z "${DESTROY}" ] && {
    set +e
    cd /app/terraform/src/03-main
    ${TF_INIT_PATH}
    terraform destroy
    cd /app/terraform/src/02-ecr
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

#########################################################
Create TF Statefile s3 bucket /app/terraform/src/00-init
#########################################################

EOF

# TODO test if exists
cd /app/terraform/src/00-init
${TF_INIT_PATH}

terraform apply

AWS_ACCOUNT_NUMBER=$(echo "data.aws_caller_identity.main.account_id" | terraform console)

cat << EOF

###########################################
# Building VPC /app/terraform/src/01-vpc" #
###########################################

EOF

cd /app/terraform/src/01-vpc
${TF_INIT_PATH}

terraform apply

cat << EOF

###########################################################
# Building ECR Docker Registry /app/terraform/src/02-ecr #
###########################################################

EOF

cd /app/terraform/src/02-ecr
${TF_INIT_PATH}

#terraform plan
terraform apply
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
docker push ${REMOTE_IMAGE_URL}

# Deploy ECS Jenkins
cat << EOF

###########################################################
# Building ECS Jenkins Service /app/terraform/src/03-main #
###########################################################

EOF

cd /app/terraform/src/03-main
${TF_INIT_PATH}

terraform apply

ELB_HOSTNAME=$(echo "aws_alb.main.dns_name" | terraform console)

cat << EOF

##################################################################################
#              yawn... I'm going to take a nap for 3 minutes.                    #
# We'll need to wait for EC2 instances, ECS service and LB Healthchecks to pass. #
##################################################################################

EOF

sleep 180

# TODO readiness loop

cat << EOF

#########################################################################
#                 We now have a toolkit in the cloud                    #
#                                                                       #
#   http://${ELB_HOSTNAME}/   #
#                                                                       #
#########################################################################

EOF
