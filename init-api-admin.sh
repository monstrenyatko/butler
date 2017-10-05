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
MANAGE="$COMPOSE -f docker-compose.yml run --rm -T $service manage.py"

password=$(cat $BUTLER_HOME/api/django-admin-password)

$MANAGE shell -c \
"from django.contrib.auth.models import User;"\
"User.objects.filter(email='admin@example.com').delete();"\
"User.objects.create_superuser('admin', 'admin@example.com', '$password')"

set +x
echo $'\n'"[DONE] API admin"
