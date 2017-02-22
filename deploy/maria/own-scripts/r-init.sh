#!/usr/bin/env bash
# Run this command to init the maria db container right from your own, remote machine
# Make sure you have environment vars target the proper machine and build
# We need solr service running for the init to take place

echo Connecting with user ${EDW_DEPLOY_USER:NONE} and host ${EDW_DEPLOY_HOST:NONE}
echo Running docker-compose on remote from dir ${EDW_DEPLOY_DIR:NONE}
echo Make sure you have one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD env vars defined
echo Make sure you have ecolex DATABASE vars defined MYSQL_DATABASE, MYSQL_USER and MYSQL_PASSWORD

ssh -q -t $EDW_DEPLOY_USER@$EDW_DEPLOY_HOST "cd $EDW_DEPLOY_DIR || exit 1 ; \
env \`xargs < .env\` docker-compose stop >/dev/null 2>&1 || true ;\
docker stop mysql_db_creator >/dev/null 2>&1 || true ;\
env \`xargs < .env\` docker-compose run --name=mysql_db_creator -d maria mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci $@ && \
echo Sleeping for 45 seconds to make sure db is created in the background ;\
sleep 45 ;\
docker logs mysql_db_creator ;\
docker stop mysql_db_creator >/dev/null 2>&1 || true ;\
docker rm mysql_db_creator >/dev/null 2>&1 || true ;\
"
