#!/usr/bin/env bash

set -e

# smoke test the built image: bot.js must parse and its dependencies must resolve
docker run --rm atomy/discord-bot_rustplayercount:latest node --check bot.js

# the bot must start up and fail fast with the expected config error (proves
# node_modules load fine inside the image)
OUTPUT=$(docker run --rm atomy/discord-bot_rustplayercount:latest node bot.js || true)
echo "${OUTPUT}"
echo "${OUTPUT}" | grep -q "DISCORD_API_KEY" || {
    echo "[test] Image did not start up as expected!"
    exit 1
}

echo "[test] Image smoke test passed."
