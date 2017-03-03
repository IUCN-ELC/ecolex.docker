#!/usr/bin/env bash

set -e

rm sqlite_dump_*.json || true

cp ecolex/local_settings.sqlite.example ecolex/local_settings.py

echo "Dumping sqlite db to database.json"
echo "=================================="
echo
./manage.py dump_sqlite
rm ecolex/local_settings.py


./manage.py migrate --run-syncdb
./manage.py clear_django_contenttypes

echo "Reload data from database.json"
echo "=============================="
echo
ls -1 sqlite_dump_*.json |sort |xargs ./manage.py iloaddata

rm sqlite_dump_*.json