#!/usr/bin/env bash

set -e

: "${ECR_REGISTRY:?ECR_REGISTRY environment variable is required}"

docker build -t atomy/discord-bot_rustplayercount:latest .

docker tag atomy/discord-bot_rustplayercount:latest ${ECR_REGISTRY}/atomy/discord-bot_rustplayercount:latest
