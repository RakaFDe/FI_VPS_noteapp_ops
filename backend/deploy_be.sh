#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Load image version"
export $(grep -v '^#' image.env | xargs)

echo "Pull images"
docker compose pull

echo "Run database migration"
docker compose --profile migration up --abort-on-container-exit migrate

echo "Jalankan compose"
docker compose up -d --remove-orphans

echo "Clean unused images"
docker image prune -f

echo "* Deploy finished *"