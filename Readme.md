# FINOTE OPS - Cluster Recovery Guide

## Overview

Repository ini berisi manifest Kubernetes dan konfigurasi GitOps untuk FINOTE.

Komponen yang dikelola:

* PostgreSQL
* Backend API
* Frontend
* Migration Job
* Ingress

Deployment aplikasi dikelola menggunakan ArgoCD.

Secret tidak disimpan di repository dan harus direstore secara terpisah.

---

# Current Architecture

```text
Internet
    │
    ▼
NGINX Bare Metal
    │
    ▼
NodePort Service
    │
    ▼
Kubernetes Cluster
```

NGINX Bare Metal bertindak sebagai reverse proxy menuju service Kubernetes yang diekspos menggunakan NodePort.

---

# Repository Structure

```text
backend/
├── k8s/
│   ├── app/
│   ├── migrate/
│   └── postgres/

frontend/
├── k8s/

scripts/
├── archive/
└── maintenance/
    └── run-migration.sh
```

---

# Disaster Recovery Procedure

## 1. Prepare Kubernetes Cluster

Install:

* containerd
* kubeadm
* kubelet
* kubectl

Initialize cluster:

```bash
kubeadm init
```

Install CNI plugin.

Verify cluster:

```bash
kubectl get nodes
```

All nodes should be Ready.

---

## 2. Install ArgoCD

Create namespace:

```bash
kubectl create namespace argocd
```

Install ArgoCD:

```bash
kubectl apply --server-side \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

If required, re-apply ArgoCD configuration used by this environment (server.insecure, ingress configuration, etc).

Verify:

```bash
kubectl get pods -n argocd
```

All pods should be Running.

---

## 3. Restore Secrets

Secrets are not stored in Git.

Restore:

* finote-postgres-secret
* finote-backend-secret

Example:

```bash
kubectl apply -f postgres-secret.yaml
kubectl apply -f backend-secret.yaml
```

Verify:

```bash
kubectl get secret
```

---

## 4. Configure ArgoCD Applications

Register Git repository.

Create or restore ArgoCD Application resources.

Sync applications.

Verify:

```bash
kubectl get applications -n argocd
```

---

## 5. Verify PostgreSQL

```bash
kubectl get pods
kubectl get pvc
```

PostgreSQL must be Running.

---

## 6. Run Database Migration

Migration dijalankan menggunakan maintenance script:

```bash
./scripts/maintenance/run-migration.sh
```

Verify migration job:

```bash
kubectl get jobs
```

Migration must complete successfully.

---

## 7. Verify Backend

```bash
kubectl rollout status deployment/finote-backend
```

Backend must be Available.

---

## 8. Verify Frontend

```bash
kubectl rollout status deployment/finote-frontend
```

Frontend must be Available.

---

## 9. Post Recovery Validation

Validate:

* Frontend accessible
* Backend API accessible
* Login works
* Database connection works
* Notes CRUD works

---

# Operational Notes

* ArgoCD is the source of deployment truth.
* Kubernetes Secrets are managed outside Git.
* Legacy deployment scripts have been archived.
* Migration is executed manually through maintenance scripts when required.

---

# Future Architecture

Target architecture:

```text
Internet
    │
    ▼
Load Balancer
    │
    ▼
NGINX Ingress Controller
    │
    ▼
Ingress Resource
    │
    ▼
Service
    │
    ▼
Pod
```

Planned additions:

* NGINX Ingress Controller
* cert-manager
* TLS automation
* Sealed Secrets / External Secrets
* Monitoring Stack
* Ansible bootstrap automation
* GitOps full recovery
* Multi-node Kubernetes cluster

```
```
