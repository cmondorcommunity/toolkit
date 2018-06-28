#!/usr/bin/env bash

TFENV="/usr/local/bin/tfenv"

${TFENV} install 0.11.7
${TFENV} use 0.11.7

terraform version
