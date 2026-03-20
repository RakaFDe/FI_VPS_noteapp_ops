#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "Login to GHCR"
echo $GHCR_TOKEN | docker login ghcr.io -u $GHCR_USER --password-stdin

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Load image version"
export $(grep -v '^#' image.env | xargs)

echo "Pull latest image"
docker compose pull

echo "Restart frontend"
docker compose up -d --remove-orphans

echo "Clean unused images"
docker image prune -f

echo "* Frontend deploy finished *"