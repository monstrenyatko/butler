#!/bin/bash

set -e
set -v


DOCKER='docker'
COMPOSE='docker-compose'
if [ -n "$1" ]; then
	COMPOSE="$COMPOSE -p $1"
fi

service='mariadb'
$COMPOSE exec $service sh -c "mysql --defaults-extra-file=/run/secrets/mariadb-root-options -h localhost"
