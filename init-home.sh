#!/bin/bash

source $(dirname $0)/functions.sh

set -e
set -x

load_env "${ENV_FILE:-.env}"

mkdir -p $BUTLER_HOME/cert
mkdir -p $BUTLER_HOME/fw

cp -R ./config/nginx $BUTLER_HOME
cp -R ./config/mosquitto $BUTLER_HOME
