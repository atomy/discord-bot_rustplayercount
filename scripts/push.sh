#!/usr/bin/env bash

set -e

: "${ECR_REGISTRY:?ECR_REGISTRY environment variable is required}"

docker push ${ECR_REGISTRY}/atomy/discord-bot_rustplayercount:latest
