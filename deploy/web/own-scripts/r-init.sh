#!/usr/bin/env bash
# Run this command to init the web container right from your own, remote machine
# Make user you have environment vars target the proper machine and build
# We need solr service running for the init to take place

echo Connecting with user ${EDW_DEPLOY_USER:NONE} and host ${EDW_DEPLOY_HOST:NONE}
echo Running docker-compose on remote from dir ${EDW_DEPLOY_DIR:NONE}

ssh -q -t $EDW_DEPLOY_USER@$EDW_DEPLOY_HOST "cd $EDW_DEPLOY_DIR || exit 1 ; \
env \`xargs < .env\` docker-compose stop >/dev/null 2>&1 || true ;\
env \`xargs < .env\` docker-compose run --rm web init $@;\
env \`xargs < .env\` docker-compose stop || true \;
"
