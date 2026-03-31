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

echo "Apply ConfigMap & Secret"
kubectl apply -f backend/k8s/backend-configmap.yaml
kubectl apply -f backend/k8s/backend-secret.yaml
kubectl apply -f backend/k8s/postgres-secret.yaml

echo "Apply Postgres (PVC, Service, StatefulSet)"
kubectl apply -f backend/k8s/postgres-pvc.yaml
kubectl apply -f backend/k8s/postgres-service.yaml
kubectl apply -f backend/k8s/postgres-statefulset.yaml

echo "Wait Postgres ready"
kubectl rollout status statefulset/finote-postgres --timeout=120s || true

echo "Run migration job"
envsubst < backend/k8s/postgres-migrate-job.yaml | kubectl apply -f -

echo "Apply Backend deployment"
envsubst < backend/k8s/backend-deployment.yaml | kubectl apply -f -

echo "Apply Backend service"
kubectl apply -f backend/k8s/backend-service.yaml

echo "Wait rollout backend"
kubectl rollout status deployment/finote-backend

echo "Backend deployed via Kubernetes success!"
