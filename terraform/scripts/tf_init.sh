#!/usr/bin/env bash

#clean
[ -d .terraform ] && {
    echo "cleaning .terraform dir"
    rm -rf .terraform
}

[ -f terraform.tfvars ] && {
    echo "unlinking terraform.tfvars"
    rm -rf terraform.tfvars
}

[ -f override.tf ] && {
    echo "unlinking override.tf"
    rm -rf override.tf
}

#config
#use terraform.tfvars to inject Docker environment value into terraform via file https://www.terraform.io/intro/getting-started/variables.html#from-a-file
[ -z "${ENVIRONMENT_NAME}" ] && {
    echo "Setting Environment name ${ENVIRONMENT_NAME}"
    echo "environment_name = \"${ENVIRONMENT_NAME}\"" >> terraform.tfvars
}

# use overrides  https://www.terraform.io/docs/configuration/override.html
[ -d overrides ] && {
    [ -z "${MY_ENV}" ] && {
        [ -f overrides/${MY_ENV}.tf ] && {
            ln -s overrides/${MY_ENV}.tf override.tf
        }
    }
}

#initialize terraform
echo "running: terraform init"
terraform init

#basic linting
echo "running: terraform validate"
terraform validate
