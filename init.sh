#!/bin/bash

source $(dirname $0)/functions.sh

set -e
set -x

load_env "${ENV_FILE:-.env}"

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
./init-api-admin.sh
./init-api-static.sh

touch $BUTLER_HOME/initialized
