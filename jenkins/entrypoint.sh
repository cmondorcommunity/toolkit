#!/bin/bash

if [ ! -z "$@" ]; then
    # CMD was specified, pass through to old entrypoint
    exec /usr/local/bin/jenkins.sh "$@"
else
    set -x
    echo "--== Jenkins ==--"
    if [ -f "/var/jenkins_home/config.xml" ]; then
        echo "Jenkins has already been bootstrapped, starting up ..."
        exec /usr/local/bin/jenkins.sh "$@"
    else
        cat <<EOF > /var/jenkins_home/.gitconfig
[user]
        email = jenkins@cmondorcommunity.com
        name = cmondorcommunity
EOF
        echo "/var/jenkins_home/.gitconfig:"
        cat /var/jenkins_home/.gitconfig

        echo "Jenkins configuration complete."
        exec /usr/local/bin/jenkins.sh "$@"
    fi
fi
