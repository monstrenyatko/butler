#!/bin/bash

DOCKER='docker'
COMPOSE='docker-compose'
if [ -n "$1" ]; then
	COMPOSE="$COMPOSE -p $1"
fi

set -e
set -x

service='api'
MANAGE="$COMPOSE -f docker-compose.yml run --rm -T $service manage.py"

$MANAGE migrate
$MANAGE createcertca
$MANAGE createcertserver --name $BUTLER_HOST
$MANAGE rotatecertserver --name $BUTLER_HOST
$MANAGE updatecertserverfingerprint --name $BUTLER_HOST

set +x
echo $'\n'"[DONE] certificates"
