#!/usr/bin/env bash

set -e

# DISCORD_WEBHOOK_URL must be set as an environment variable / GitHub secret
APP_NAME=discord-bot_rustplayercount
CHANGES=`cat changes`

curl -X POST \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"Pipeline-Release\", \"content\": \"[`hostname`] Released **${APP_NAME}** -- **<current-version>** -> **<new-version>**\n${CHANGES}\"}" \
  ${DISCORD_WEBHOOK_URL}
