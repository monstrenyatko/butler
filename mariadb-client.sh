#!/bin/bash

set -e
set -x


DOCKER='docker'
COMPOSE='docker-compose'
if [ -n "$1" ]; then
	COMPOSE="$COMPOSE -p $1"
fi

service='mariadb'
$COMPOSE exec $service sh -c "mysql -h localhost -u butler --password=\$(cat /run/secrets/mariadb-db-password)"
