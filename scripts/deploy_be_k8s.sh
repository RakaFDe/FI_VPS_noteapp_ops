#!/bin/bash
set -e

echo "Move to repo root"
cd "$(dirname "$0")/.."

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Apply Postgres"
kubectl apply -f backend/k8s/postgres-pvc.yaml
kubectl apply -f backend/k8s/postgres-service.yaml
kubectl apply -f backend/k8s/postgres-statefulset.yaml

echo "Wait Postgres ready"
kubectl rollout status statefulset/finote-postgres --timeout=120s || true

echo "Run migration job"
kubectl apply -f backend/k8s/postgres-migrate-job.yaml

echo "Deploy backend via kustomize"
kubectl apply -k backend

echo "Wait rollout backend"
kubectl rollout status deployment/finote-backend

echo "Backend deployed via Kubernetes success!"