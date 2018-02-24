#!/bin/bash

source $(dirname $0)/functions.sh

set -e
set -x

load_env "${ENV_FILE:-.env}"

COMPOSE='docker-compose'
if [ -n "$1" ]; then
	COMPOSE="$COMPOSE -p $1"
fi

service='grafana nginx'
$COMPOSE -f docker-compose.yml up -d $service

set +x
set -v

{
	echo '{';
	echo -n '"oldPassword": "admin"'; echo ',';
	echo -n '"newPassword": "'; cat $BUTLER_HOME/api/django-admin-password | tr -d '\n'; echo '",';
	echo -n '"confirmNew": "'; cat $BUTLER_HOME/api/django-admin-password | tr -d '\n'; echo '"';
	echo '}';
} | curl -X PUT -H "Content-Type: application/json" --cacert $BUTLER_HOME/cert/ca/ca.crt.pem \
		-d @- https://admin:admin@$BUTLER_HOST:8043/grafana/api/user/password

set +v
echo $'\n'"[DONE] Grafana"
