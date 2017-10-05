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
MANAGE="$COMPOSE -f docker-compose.yml run --rm -T \
  -e BUTLER_API_DJANGO_ADMIN_EMAIL \
  -e BUTLER_API_DJANGO_ADMIN_PASSWORD=$(cat $BUTLER_HOME/api/django-admin-password) \
  $service manage.py"

$MANAGE shell -c \
"from django.contrib.auth.models import User;"\
"User.objects.filter(username='admin').delete();"\
"User.objects.create_superuser('admin',"\
" os.environ['BUTLER_API_DJANGO_ADMIN_EMAIL'],"\
" os.environ['BUTLER_API_DJANGO_ADMIN_PASSWORD'])"

set +x
echo $'\n'"[DONE] API admin"
