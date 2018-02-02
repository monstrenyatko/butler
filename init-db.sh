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
echo $'\n'"[READY] MariaDB"
set -v
MARIADB_CLIENT=( $DOCKER exec -i $service_id sh -c "mysql --defaults-extra-file=/run/secrets/mariadb-root-options -h localhost" )
echo "CREATE DATABASE IF NOT EXISTS \`$BUTLER_MYSQL_GRAFANA_DATABASE\` ;" | "${MARIADB_CLIENT[@]}"
MARIADB_CLIENT+=( "$BUTLER_MYSQL_GRAFANA_DATABASE" )
echo "CREATE USER IF NOT EXISTS '$BUTLER_MYSQL_GRAFANA_USER'@'%' IDENTIFIED BY '$(cat $BUTLER_HOME/mariadb/grafana-db-password)' ;" | "${MARIADB_CLIENT[@]}"
echo "GRANT ALL ON \`$BUTLER_MYSQL_GRAFANA_DATABASE\`.* TO '$BUTLER_MYSQL_GRAFANA_USER'@'%' ;" | "${MARIADB_CLIENT[@]}"
echo 'FLUSH PRIVILEGES ;' | "${MARIADB_CLIENT[@]}"
set +v
echo $'\n'"[DONE] MariaDB"

set -x
service='influxdb'
$COMPOSE -f docker-compose.yml -f docker-compose-init-db.yml run --rm $service influxdb-app db-init
$COMPOSE -f docker-compose.yml -f docker-compose-init-db.yml up -d $service
service_id=$($COMPOSE ps -q $service)
set +x
echo $'\n'"[READY] InfluxDB"
set -v
INFLUXDB_CLIENT=(
	$DOCKER exec -i $service_id sh -c
	"influx -host localhost -username root -password=\$(cat /run/secrets/influxdb-root-password)"
	-execute
)
echo "CREATE USER \"$BUTLER_INFLUXDB_GRAFANA_USER\" WITH PASSWORD '$(cat $BUTLER_HOME/influxdb/grafana-db-password)' ;" | "${INFLUXDB_CLIENT[@]}"
echo "GRANT READ ON \"$BUTLER_INFLUXDB_GRAFANA_DATABASE\" TO \"$BUTLER_INFLUXDB_GRAFANA_USER\" ;" | "${INFLUXDB_CLIENT[@]}"
set +v
echo $'\n'"[DONE] InfluxDB"
