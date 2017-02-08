#!/usr/bin/env bash

#echo Connecting with user $EDW_DEPLOY_USER and host $EDW_DEPLOY_HOST
#echo Running docker-compose on remote from dir $EDW_DEPLOY_DIR
#docker-compose exec solr config-diff.sh

ssh -q -t $EDW_DEPLOY_USER@$EDW_DEPLOY_HOST "cd ${EDW_DEPLOY_DIR} && \
env \`xargs < .env\` docker-compose exec solr config-diff.sh"
