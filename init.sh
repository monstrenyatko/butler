#!/bin/bash

set -e
set -x

ENV_FILE=".env"
# load variables from file if not already set
while read -r line || [ -n "$line" ]; do
    if [ -n "$line" ] && [[ ! "$line" =~ ^\s*# ]]; then
        env_name=$(echo "$line" | cut -d "=" -f 1)
        if [ -z "${!env_name}" ]; then
            export "$line"
        fi
    fi
done < $ENV_FILE

INITIALIZED_FILE=$BUTLER_HOME/initialized

if [ -e $INITIALIZED_FILE ]; then
	set +x
	echo "Already initialized. Please delete BUTLER_HOME [$BUTLER_HOME]..."
	exit 1
fi

mkdir -p $BUTLER_HOME

./init-home.sh
./init-secrets.sh
./init-db.sh
./init-cert.sh

touch $BUTLER_HOME/initialized
