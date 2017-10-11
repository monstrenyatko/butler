#!/bin/bash

source $(dirname $0)/functions.sh

set -e
set -x

load_env "${ENV_FILE:-.env}"
load_env "${PULL_ENV_FILE:-$1}"

DOCKER='docker'

set +x
echo $'\n'"[START] pull"$'\n'
set -x

$DOCKER pull $BUTLER_IMG_SRC_MOSQUITTO
$DOCKER tag $BUTLER_IMG_SRC_MOSQUITTO $BUTLER_IMG_MOSQUITTO

$DOCKER pull $BUTLER_IMG_SRC_MARIADB
$DOCKER tag $BUTLER_IMG_SRC_MARIADB $BUTLER_IMG_MARIADB

$DOCKER pull $BUTLER_IMG_SRC_NGINX
$DOCKER tag $BUTLER_IMG_SRC_NGINX $BUTLER_IMG_NGINX

$DOCKER pull $BUTLER_IMG_SRC_BUTLER_API
$DOCKER tag $BUTLER_IMG_SRC_BUTLER_API $BUTLER_IMG_BUTLER_API

set +x
echo $'\n'"[DONE] pull"
