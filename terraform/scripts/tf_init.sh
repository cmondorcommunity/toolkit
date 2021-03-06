#!/usr/bin/env bash

set -x

#clean
echo " Cleaning "
[ -d .terraform ] && {
    rm -rf .terraform
}

#[ -f terraform.tfvars ] && {
#    rm -rf terraform.tfvars
#}

[ -f override.tf ] && {
    rm -rf override.tf
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

[ -z "${ORG}" ] && {
    echo "####### ORG NOT SET, see README.md  ########"
    exit 1
}

if [ "${PHASE}" = "00-init" ]; then
    terraform init -input=false
else
    terraform init -input=false -backend-config="key=\"$PHASE-$REGION-terraform.tfstate\"" -backend-config="bucket=\"${ORG}-tlkt-tfstate\""
fi

terraform validate
