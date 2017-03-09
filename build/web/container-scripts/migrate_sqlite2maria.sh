#!/usr/bin/env bash

set -e

rm sqlite_dump_*.json || true

cp ecolex/local_settings.sqlite.example ecolex/local_settings.py

echo "Dumping sqlite db to database.json"
echo "=================================="
echo
./manage.py dump_sqlite
rm ecolex/local_settings.py
# let autoincrement do its work on DocumentText
mv sqlite_dump_00000.json sqlite_dump_00000.bak
for f in sqlite_dump_*.json; do
    sed  -i -e's/"pk": [0-9]\+/"pk": null/' $f
done
mv sqlite_dump_00000.bak sqlite_dump_00000.json


./manage.py migrate --run-syncdb
./manage.py clear_django_contenttypes

echo "Reload data from database.json"
echo "=============================="
echo
for f in `ls -1 sqlite_dump_*.json |sort`; do
    echo loading $f
    ./manage.py iloaddata $f
done

rm sqlite_dump_*.json