#!/bin/bash

set -e


DOCKER='docker'
COMPOSE='docker-compose'
if [ -n "$1" ]; then
	COMPOSE="$COMPOSE -p $1"
fi

service='mariadb'
$COMPOSE exec $service sh -c "mysqldump -h localhost -u butler --password=\$(cat /run/secrets/mariadb-db-password) butler"
