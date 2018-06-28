#!/usr/bin/env bash

TFENV="/usr/local/bin/tfenv"

${TFENV} install 0.11.7
${TFENV} use 0.11.7

echo "entering /app/terraform/src/00-init"
cd /app/terraform/src/00-init

echo "running ../scripts/tf_init.sh"
exec ../scripts/tf_init.sh

terraform apply

echo "entering /app/terraform/src/01-vpc"
cd /app/terraform/src/01-vpc

echo "running ../scripts/tf_init.sh"
exec ../scripts/tf_init.sh

terraform apply

echo "entering /app/terraform/src/02-main"
cd /app/terraform/src/02-main

echo "running ../scripts/tf_init.sh"
exec ../scripts/tf_init.sh

terraform apply
