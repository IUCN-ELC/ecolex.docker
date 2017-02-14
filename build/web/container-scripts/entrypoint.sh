#!/usr/bin/env bash

init() {
    ./manage.py migrate
    ./manage.py collectstatic --noinput
}

init_bare() {
    init
    ./manage.py loaddata ecolex/fixtures/initial_data.json
    if [ "$1" = "solr" ]; then
        cp ecolex/local_settings.initial_example ecolex/local_settings.py
        import_updater.sh
        rm ecolex/local_settings.py
    fi
}

wait_sql() {
    while ! nc -z maria 3306; do
        echo "Waiting for MySQL server maria:3306 ..."
        sleep 1
    done
}


if [ "$1" == "run" ]; then
    wait_sql
    init
    exec uwsgi config_file
elif [ "$1" == "debug" ]; then
    wait_sql
    exec ./manage.py runserver 0.0.0.0:$EDW_WEB_PORT
elif [ "$1" == "init" ]; then
    shift
    wait_sql
    init_bare "$@"
else
    exec "$@"
fi