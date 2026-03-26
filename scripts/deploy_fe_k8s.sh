#!/bin/bash

set -e

echo "Move to repo root"
cd "$(dirname "$0")/.."

#echo "Login to GHCR"
#echo $GHCR_TOKEN | docker login ghcr.io -u $GHCR_USER --password-stdin

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Load frontend image env"
export $(grep -v '^#' frontend/image.env | xargs)

echo "Using image: $FRONTEND_IMAGE"

echo "Apply Kubernetes manifests"

envsubst < frontend/k8s/frontend-deployment.yaml | kubectl apply -f -
kubectl apply -f frontend/k8s/frontend-service.yaml

echo "Wait rollout deployment"
kubectl kubectl rollout status deployment/finote-frontend

echo "Frontend deployed via Kubernetes"