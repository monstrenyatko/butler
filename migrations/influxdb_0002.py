#!/usr/bin/env python3

# Migration of the unspecified region value
#
# measurements: TEMPERATURE, HUMIDITY
# {region=DEFAULT} => {region=A}
# drop {region=DEFAULT}

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


def convert(db_client, measurement, src_region, dst_region, limit=20000):
    src_count = next(db_client.query('SELECT count(value) FROM {} WHERE "region" = \'{}\''.format(measurement, src_region)).get_points(), {}).get('count', 0)
    dst_count_start = next(db_client.query('SELECT count(value) FROM {} WHERE "region" = \'{}\''.format(measurement, dst_region)).get_points(), {}).get('count', 0)
    logger.info('Records to process: %d', src_count)
    for offset in range(0, src_count, limit):
        src_points = db_client.query(
            'SELECT * FROM {} WHERE "region" = \'{}\' LIMIT {} OFFSET {}'.format(measurement, src_region, limit, offset)
        ).get_points()
        dst_points = [
            {
                'measurement': measurement,
                'time': i['time'],
                'tags': {
                    'location': i['location'],
                    'region': dst_region,
                },
                'fields': {
                    'value': float(i['value']),
                }
            }
            for i in src_points
        ]
        counter_stop = 5
        for counter in range(0, counter_stop):
            try:
                db_client.write_points(
                    points=dst_points,
                )
                break
            except InfluxDBServerError as e:
                logger.warn('DB write problem: {}', str(e))
                if counter + 1 >= counter_stop:
                    raise
                else:
                    time.sleep(10)
    dst_count_stop = next(db_client.query('SELECT count(value) FROM {} WHERE "region" = \'{}\''.format(measurement, dst_region)).get_points(), {}).get('count', 0)
    logger.info('Updated records: %d', dst_count_stop - dst_count_start)
    db_client.delete_series(measurement=measurement, tags={'region':src_region})


db_settings = {
    'host': 'localhost',
    'port': '8086',
    'database': 'butler',
    'username': 'butler',
    'password': None,
}
with open(cli_args['db_password_file'], 'r') as f:
    db_settings['password'] = f.read().replace('\n', '')
db_client = InfluxDBClient(**db_settings)

for i in db_client.get_list_measurements():
    measurement = i['name']
    logger.info('Processing measurement: %s', measurement)
    for src_region,dst_region in [('DEFAULT', 'A'),]:
        convert(
            db_client=db_client,
            measurement=measurement,
            src_region=src_region,
            dst_region=dst_region,
        )
