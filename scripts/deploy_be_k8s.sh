#!/bin/bash
set -e

echo "Move to repo root"
cd "$(dirname "$0")/.."

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Load backend image"
export $(grep -v '^#' backend/image.env | xargs)

echo "Deploy backend"

envsubst < backend/k8s/backend-deployment.yaml | kubectl apply -f -
kubectl apply -f backend/k8s/backend-service.yaml

echo "Wait rollout"
kubectl rollout status deployment/finote-backend

echo "Backend deployed successfully"