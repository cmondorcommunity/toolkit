#!/usr/bin/env bash

WAN_IP=$(curl -sSL http://whatismyip.akamai.com/)

echo '{"ip":"'"${WAN_IP}"'"}'
