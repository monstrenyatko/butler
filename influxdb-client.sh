#!/bin/bash

set -e
set -x


DOCKER='docker'
COMPOSE='docker-compose'
if [ -n "$1" ]; then
	COMPOSE="$COMPOSE -p $1"
fi

service='influxdb'
$COMPOSE exec $service sh -c "influx -host localhost -username butler -database butler -precision rfc3339 -password=\$(cat /run/secrets/influxdb-db-password)"
