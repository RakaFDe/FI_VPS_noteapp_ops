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

CHANGE="Deploy $BACKEND_IMAGE commit $(git rev-parse --short HEAD)"

echo "Annotate deployment revision"
kubectl annotate deployment finote-backend \
  kubernetes.io/change-cause="$CHANGE" \
  --overwrite

echo "Wait rollout backend"
kubectl rollout status deployment/finote-backend

echo "Backend redeployed successfully!"