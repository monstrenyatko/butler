#!/usr/bin/env python3

# Migration from the previous DB format
#
# measurements: TEMPERATURE, HUMIDITY
# {id=A571-C8B7} => {location=LIVING_ROOM, region=DEFAULT}

import os
import logging
import argparse
import time
import pprint
from influxdb import InfluxDBClient
from influxdb.exceptions import InfluxDBServerError


def logPretty(logger, value, message=None, level=logging.INFO):
    fmt = ''
    if message:
        fmt += message
    fmt += os.linesep + '%s'
    logger.log(level, fmt, pprint.pformat(value))


logging.basicConfig(format='%(asctime)s [%(name)s] [%(levelname)s] %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

cli_arg_parser = argparse.ArgumentParser()
cli_arg_parser.add_argument('--db-password-file', required=True, help='DB password fileB')
cli_args = vars(cli_arg_parser.parse_args())


def convert(src_db_client, dst_db_client, src_measurement, dst_measurement, src_id, dst_tags=None, limit=20000):
    src_count = next(src_db_client.query('SELECT count(value) FROM {} WHERE "id" = \'{}\''.format(src_measurement, src_id)).get_points(), {}).get('count', 0)
    for offset in range(0, src_count, limit):
        src_points = src_db_client.query(
            'SELECT time,value FROM {} WHERE "id" = \'{}\' LIMIT {} OFFSET {}'.format(src_measurement, src_id, limit, offset)
        ).get_points()
        dst_points = [
            {
                'measurement': dst_measurement,
                'time': i['time'],
                'fields': {
                    'value': float(i['value']),
                }
            }
            for i in src_points
        ]
        counter_stop = 5
        for counter in range(0, counter_stop):
            try:
                dst_db_client.write_points(
                    points=dst_points,
                    tags=dst_tags
                )
                break
            except InfluxDBServerError as e:
                logger.warn('DB write problem: {}', str(e))
                if counter + 1 >= counter_stop:
                    raise
                else:
                    time.sleep(10)


src_db_settings = {
    'host': 'localhost',
    'port': '8086',
    'database': 'butler',
}
src_db_client = InfluxDBClient(**src_db_settings)

dst_db_settings = {
    'host': 'localhost',
    'port': '8186',
    'database': 'butler',
    'username': 'butler',
    'password': None,
}
with open(cli_args['db_password_file'], 'r') as f:
    dst_db_settings['password'] = f.read().replace('\n', '')
dst_db_client = InfluxDBClient(**dst_db_settings)

src_id = 'A571-C8B7'
dst_tags = {
    'location': 'LIVING_ROOM',
    'region': 'DEFAULT',
}

for src_measurement,dst_measurement in [('TEMPERATURE', 'TEMPERATURE'), ('HUMIDITY', 'HUMIDITY')]:
    convert(
        src_db_client=src_db_client,
        dst_db_client=dst_db_client,
        src_measurement=src_measurement,
        dst_measurement=dst_measurement,
        src_id=src_id,
        dst_tags=dst_tags,
    )
