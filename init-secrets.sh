#!/bin/bash

source $(dirname $0)/functions.sh

set -e
set -x

load_env "${ENV_FILE:-.env}"

# MYSQL_ROOT_PASSWORD
dir=$BUTLER_HOME/mariadb; \
file=$dir/root-password; \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file

# MYSQL_PASSWORD
dir=$BUTLER_HOME/mariadb; \
file=$dir/db-password; \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file

# BUTLER_API_DJANGO_SECRET_KEY
dir=$BUTLER_HOME/api; \
file=$dir/django-secret-key; \
gen="import random; print(''.join([random.SystemRandom().choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)') for i in range(50)]))"; \
mkdir -p $dir && \
python -c "$gen" > $file && \
chmod go-rwx $file
