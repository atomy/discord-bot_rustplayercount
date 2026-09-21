#!/bin/bash

set -e

: "${ECR_REGISTRY:?ECR_REGISTRY environment variable is required}"
: "${DEPLOY_USER:?DEPLOY_USER environment variable is required}"
: "${DEPLOY_HOST:?DEPLOY_HOST environment variable is required}"
: "${DEPLOY_PATH:?DEPLOY_PATH environment variable is required}"
: "${DISCORD_API_KEY:?DISCORD_API_KEY environment variable is required}"
: "${SERVER_IP:?SERVER_IP environment variable is required}"
: "${SERVER_RCONPORT:?SERVER_RCONPORT environment variable is required}"
: "${SERVER_RCONPASSWORD:?SERVER_RCONPASSWORD environment variable is required}"

# render docker-compose.yml from the dist template
cp docker-compose.yml.dist docker-compose.deploy.yml
sed -i "s|<ecr-registry>|${ECR_REGISTRY}|" docker-compose.deploy.yml
sed -i "s|<discord-api-key>|${DISCORD_API_KEY}|" docker-compose.deploy.yml
sed -i "s|<server-ip>|${SERVER_IP}|" docker-compose.deploy.yml
sed -i "s|<server-rconport>|${SERVER_RCONPORT}|" docker-compose.deploy.yml
sed -i "s|<server-rconpassword>|${SERVER_RCONPASSWORD}|" docker-compose.deploy.yml

scp ~/.docker/config.json ${DEPLOY_USER}@${DEPLOY_HOST}:~/.docker/config.json
scp docker-compose.deploy.yml ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/docker-compose.yml
rm -f docker-compose.deploy.yml
ssh ${DEPLOY_USER}@${DEPLOY_HOST} "cd ${DEPLOY_PATH} && docker compose pull && (docker compose down || true) && docker compose up -d --remove-orphans"
