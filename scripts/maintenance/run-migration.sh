#!/bin/bash
set -e

echo "Delete old migration job"
kubectl delete job finote-migrate --ignore-not-found

echo "Run migration"
kubectl apply -k backend/k8s/migrate

echo "Wait migration complete"
kubectl wait 
--for=condition=complete 
job/finote-migrate 
--timeout=180s

echo "Migration completed successfully"
