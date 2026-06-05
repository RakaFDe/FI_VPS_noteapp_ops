#!/bin/bash
set -e

echo "Move to repo root"
cd "$(dirname "$0")/.."

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

echo "Apply Postgres"
kubectl apply -f backend/k8s/postgres/

echo "Wait Postgres ready"
kubectl rollout status statefulset/finote-postgres --timeout=180s || true

echo "Cleaning up old migration job if exists"
kubectl delete job finote-migrate --ignore-not-found

#echo "Run migration job"
kubectl apply -k backend/k8s/migrate/

echo "Wait migration complete"
if kubectl wait --for=condition=complete job/finote-migrate --timeout=120s; then
    echo "Migration successful!"
else
    echo "Migration failed or timed out! Aborting deployment."
    exit 1
fi

echo "Deploy backend"
kubectl apply -k backend/k8s/app

echo "Wait rollout backend"
kubectl rollout status deployment/finote-backend

echo "Backend deployed via Kubernetes success!"
