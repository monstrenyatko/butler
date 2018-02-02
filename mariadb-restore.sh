#!/bin/bash

set -e
set -x


DOCKER='docker'
COMPOSE='docker-compose'
if [ -n "$1" ]; then
	COMPOSE="$COMPOSE -p $1"
fi

service='mariadb'
serviceId=$($COMPOSE ps -q $service)
$DOCKER exec -i $serviceId sh -c "mysql --defaults-extra-file=/run/secrets/mariadb-root-options -h localhost butler"
