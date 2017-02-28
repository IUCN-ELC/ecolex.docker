#!/usr/bin/env bash

set -e

cp ecolex/local_settings.sqlite.example ecolex/local_settings.py

echo "Dumping sqlite db to database.json"
echo "=================================="
echo
./manage.py dumpdata > database.json
rm ecolex/local_settings.py


./manage.py migrate --run-syncdb
./manage.py clear_django_contenttypes

echo "Reload data from database.json"
echo "=============================="
echo
./manage.py iloaddata database.json

rm database.json