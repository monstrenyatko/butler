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

service='mariadb'
$COMPOSE -f docker-compose.yml -f docker-compose-init-db.yml up -d $service
service_id=$($COMPOSE ps -q $service)
set +x
echo $'\n'"[WAIT] MariaDB"
while [ $($DOCKER inspect --format "{{json .State.Health.Status }}" $service_id) != "\"healthy\"" ]; do
    printf "."
    sleep 1
done
echo $'\n'"[DONE] MariaDB"

service='influxdb'
$COMPOSE -f docker-compose.yml -f docker-compose-init-db.yml run --rm $service influxdb-app db-init
echo $'\n'"[DONE] InfluxDB"
