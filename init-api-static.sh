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
COMPOSE="$COMPOSE -f docker-compose.yml -f docker-compose-init-api-static.yml \
  run --rm -T $service"

$COMPOSE sh -c \
'set -x && set -e &&'\
'PySRC=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") &&'\
'find /mnt -mindepth 1 -delete &&'\
'cp -r -v $PySRC/django/contrib/admin/static/admin /mnt/ &&'\
'cp -r -v $PySRC/session_security/static/session_security /mnt/ &&'\
'cp -r -v $PySRC/rest_framework_swagger/static/rest_framework_swagger /mnt/'

set +x
echo $'\n'"[DONE] API static"
