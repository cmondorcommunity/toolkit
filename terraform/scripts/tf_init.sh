#!/usr/bin/env bash

set -x

#clean
echo " Cleaning "
[ -d .terraform ] && {
    rm -rf .terraform
}

[ -f terraform.tfvars ] && {
    rm -rf terraform.tfvars
}

[ -f override.tf ] && {
    rm -rf override.tf
}

#config
echo "Configurating"
#use terraform.tfvars to inject Docker environment value into terraform via file https://www.terraform.io/intro/getting-started/variables.html#from-a-file
[ ! -z "${ENVIRONMENT_NAME}" ] && {
    echo "environment_name = \"${ENVIRONMENT_NAME}\"" >> terraform.tfvars
}

# use overrides  https://www.terraform.io/docs/configuration/override.html
[ -d overrides ] && {
    echo "overrides found, linking."
    [ ! -z "${MY_ENV}" ] && {
        [ -f overrides/${MY_ENV}.tf ] && {
            ln -s overrides/${MY_ENV}.tf override.tf
        }
    }
}

# initialize terraform
PHASE=$(basename $(pwd))
REGION=$(basename $(dirname $(pwd)))
terraform init -input=false -backend-config="key=\"$PHASE-$REGION-terraform.tfstate\""
terraform validate
