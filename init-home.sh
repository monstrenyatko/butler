#!/bin/bash

set -e
set -x

mkdir -p $BUTLER_HOME/cert
mkdir -p $BUTLER_HOME/fw

cp -R ./config/nginx $BUTLER_HOME
cp -R ./config/mosquitto $BUTLER_HOME
