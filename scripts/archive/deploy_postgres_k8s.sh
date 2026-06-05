#!/bin/bash
set -e

echo "Move to repo root"
cd "$(dirname "$0")/.."

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Deploy PostgreSQL resources"

kubectl apply -f backend/k8s/postgres-secret.yaml
kubectl apply -f backend/k8s/postgres-service.yaml
kubectl apply -f backend/k8s/postgres-statefulset.yaml

CHANGE="Postgres deploy commit $(git rev-parse --short HEAD)"

kubectl annotate statefulset finote-postgres \
  kubernetes.io/change-cause="$CHANGE" \
  --overwrite

echo "Waiting PostgreSQL ready..."
kubectl rollout status statefulset/finote-postgres

echo "PostgreSQL deployed successfully"