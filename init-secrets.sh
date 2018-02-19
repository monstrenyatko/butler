#!/bin/bash

source $(dirname $0)/functions.sh

set -e
set -x

load_env "${ENV_FILE:-.env}"

# MYSQL_ROOT_PASSWORD
dir=$BUTLER_HOME/mariadb; \
file=$dir/root-password; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file \
; fi

# MYSQL_ROOT_OPTIONS_FILE
dir=$BUTLER_HOME/mariadb; \
file=$dir/root-options.cnf; \
pass_file=$dir/root-password; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
echo "[client]" > $file && \
echo "user=root" >> $file && \
echo -n "password=" >> $file && \
cat $pass_file >> $file && \
echo '' >> $file && \
chmod go-rwx $file \
; fi

# MYSQL_PASSWORD
dir=$BUTLER_HOME/mariadb; \
file=$dir/db-password; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file \
; fi

# MYSQL_GRAFANA_PASSWORD
dir=$BUTLER_HOME/mariadb; \
file=$dir/grafana-db-password; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file \
; fi

# BUTLER_API_DJANGO_SECRET_KEY
dir=$BUTLER_HOME/api; \
file=$dir/django-secret-key; \
gen="import random; print(''.join([random.SystemRandom().choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)') for i in range(50)]))"; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
python -c "$gen" > $file && \
chmod go-rwx $file \
; fi

# BUTLER_API_DJANGO_ADMIN_PASSWORD
dir=$BUTLER_HOME/api; \
file=$dir/django-admin-password; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file \
; fi

# INFLUXDB_ADMIN_PASSWORD
dir=$BUTLER_HOME/influxdb; \
file=$dir/root-password; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file \
; fi

# INFLUXDB_USER_PASSWORD
dir=$BUTLER_HOME/influxdb; \
file=$dir/db-password; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file \
; fi

# INFLUXDB_GRAFANA_PASSWORD
dir=$BUTLER_HOME/influxdb; \
file=$dir/grafana-db-password; \
if [ ! -e $file ]; then \
mkdir -p $dir && \
openssl rand -base64 20 > $file && \
chmod go-rwx $file \
; fi

