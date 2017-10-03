#!/bin/bash

source $(dirname $0)/functions.sh

set -e
set -x

load_env "${ENV_FILE:-.env}"

DOCKER='docker'
COMPOSE='docker-compose'
if [ -n "$1" ]; then
	COMPOSE="$COMPOSE -p $1"
fi

service='api'
MANAGE="$COMPOSE -f docker-compose.yml run --rm -T $service manage.py"

$MANAGE migrate
$MANAGE createcertca
$MANAGE createcertserver --name $BUTLER_HOST
$MANAGE rotatecertserver --name $BUTLER_HOST
$MANAGE updatecertserverfingerprint --name $BUTLER_HOST

set +x
echo $'\n'"[DONE] certificates"
