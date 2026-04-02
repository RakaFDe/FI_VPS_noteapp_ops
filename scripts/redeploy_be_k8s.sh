#!/bin/bash

set -e

echo "Move to repo root"
cd "$(dirname "$0")/.."

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Load backend image env"
export $(grep -v '^#' backend/image.env | xargs)

echo "Using image: $BACKEND_IMAGE"

echo "Redeploy backend only"
envsubst < backend/k8s/backend-deployment.yaml | kubectl apply -f -

echo "Wait rollout backend"
kubectl rollout status deployment/finote-backend

echo "Backend redeployed successfully!"
