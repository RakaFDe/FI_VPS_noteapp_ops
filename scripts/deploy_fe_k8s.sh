#!/bin/bash

set -e

echo "Move to repo root"
cd "$(dirname "$0")/.."

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Load frontend image env"
export $(grep -v '^#' frontend/image.env | xargs)

echo "Using image: $FRONTEND_IMAGE"

echo "Apply Kubernetes manifests"

envsubst < frontend/k8s/frontend-deployment.yaml | kubectl apply -f -
kubectl apply -f frontend/k8s/frontend-service.yaml

CHANGE="Deploy $FRONTEND_IMAGE commit $(git rev-parse --short HEAD)"

echo "Annotate deployment revision"
kubectl annotate deployment finote-frontend \
  kubernetes.io/change-cause="$CHANGE" \
  --overwrite

echo "Wait rollout deployment"
kubectl rollout status deployment/finote-frontend

echo "Frontend deployed via Kubernetes success !"