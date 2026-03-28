#!/bin/bash
set -e

echo "Move to repo root"
cd "$(dirname "$0")/.."

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Load backend image"
export $(grep -v '^#' backend/image.env | xargs)

echo "Run migration job"

envsubst < backend/k8s/migrate-job.yaml | kubectl apply -f -

echo "Wait migration job complete"
kubectl wait --for=condition=complete job/finote-migrate --timeout=120s

echo "Migration success"