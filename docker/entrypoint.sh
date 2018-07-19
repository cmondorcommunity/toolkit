#!/usr/bin/env bash


[ -z "${ORG}" ] && {
    echo "################  ORG NOT SET   ##################"
    echo "see README.md - copy .env.example to .env and add desired org setting"
}

[ -z "${PROJECT}" ] && {
    echo "################  PROJECT NOT SET   ##################"
    echo "see README.md - copy .env.example to .env and add desired project setting"
}

[ -z "${ENVIRONMENT}" ] && {
    echo "################  ENVIRONMENT NOT SET   ##################"
    echo "see README.md - copy .env.example to .env and add desired environment setting"
}

[ -z "${DOMAIN}" ] && {
    echo "################  DOMAIN NOT SET   ##################"
    echo "see README.md - copy .env.example to .env and add desired domain setting"
}

[ ! -f /app/terraform/src/00-init/terraform.tfvars ] && {
    echo "domain = \"${DOMAIN}\"" >> /app/terraform/src/00-init/terraform.tfvars
    echo "domain = \"${DOMAIN}\"" >> /app/terraform/src/01-vpc/terraform.tfvars
    echo "domain = \"${DOMAIN}\"" >> /app/terraform/src/02-toolkit/terraform.tfvars
    echo "environment = \"${ENVIRONMENT}\"" >> /app/terraform/src/00-init/terraform.tfvars
    echo "environment = \"${ENVIRONMENT}\"" >> /app/terraform/src/01-vpc/terraform.tfvars
    echo "environment = \"${ENVIRONMENT}\"" >> /app/terraform/src/02-toolkit/terraform.tfvars
    echo "org = \"${ORG}\"" >> /app/terraform/src/00-init/terraform.tfvars
    echo "org = \"${ORG}\"" >> /app/terraform/src/01-vpc/terraform.tfvars
    echo "org = \"${ORG}\"" >> /app/terraform/src/02-toolkit/terraform.tfvars
    echo "project = \"${PROJECT}\"" >> /app/terraform/src/00-init/terraform.tfvars
    echo "project = \"${PROJECT}\"" >> /app/terraform/src/01-vpc/terraform.tfvars
    echo "project = \"${PROJECT}\"" >> /app/terraform/src/02-toolkit/terraform.tfvars
    echo "aws_profile = \"${AWS_PROFILE}\"" >> /app/terraform/src/00-init/terraform.tfvars
    echo "aws_profile = \"${AWS_PROFILE}\"" >> /app/terraform/src/01-vpc/terraform.tfvars
    echo "aws_profile = \"${AWS_PROFILE}\"" >> /app/terraform/src/02-toolkit/terraform.tfvars
    echo "toolkit_hostname = \"${TOOLKIT_HOSTNAME}\"" >> /app/terraform/src/02-toolkit/terraform.tfvars
    echo "cert_hostname_override = \"${CERT_HOSTNAME_OVERRIDE}\"" >> /app/terraform/src/02-toolkit/terraform.tfvars
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
    terraform apply
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

echo "Logging into ECR: aws ecr get-login"
$(aws ecr get-login --no-include-email)
[ -z "${DEBUG}" ] && {
    set -x
}

[ -n "${TOOLKIT_SKIP_PUSH}" ] && {
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

terraform apply

TOOLKIT_FQDN=$(terraform output toolkit_fqdn)

# readiness check, sleep 5m then check every 10s
i=0
READINESS_COMMAND="curl -q -s -o /dev/null -w %{http_code} https://${TOOLKIT_FQDN}/login"
READY=`${READINESS_COMMAND}`
while [ "$READY" != "200" ]; do
    [ $i -eq 0 ] && {
        i=1
        cat << EOF
#########################################################
#                                                       #
# Waiting for Initial DNS and LoadBalancer HealthChecks #
#             sleeping 5m                               #
#########################################################
EOF
        sleep 300 # 5m
    }
    READY=$(${READINESS_COMMAND})
    sleep 10 # 10s
done

cat << EOF

########################################
#                                      #
#  The Toolkit for ${ORG} @ ${DOMAIN}  #
#        is now available at:          #
   https://${TOOLKIT_FQDN}/
#                                      #
########################################

EOF

