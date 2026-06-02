# FINOTE OPS - Cluster Recovery Guide

## Overview

Repository ini berisi manifest Kubernetes untuk:

* PostgreSQL
* Backend
* Frontend
* Migration Job
* Ingress

Deployment aplikasi dikelola menggunakan ArgoCD.

Secret tidak disimpan di repository.

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

# Disaster Recovery Procedure

## 1. Prepare Server

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

---

## 2. Install ArgoCD

Create namespace:

```bash
kubectl create namespace argocd
```

Install ArgoCD:

```bash
kubectl apply -n argocd -f <argocd-install-manifest>
```

Verify:

```bash
kubectl get pods -n argocd
```

All pods should be Running.

---

## 3. Restore Secrets

Secrets are not stored in Git.

Create:

* finote-postgres-secret
* finote-backend-secret

Example:

```bash
kubectl apply -f postgres-secret.yaml
kubectl apply -f backend-secret.yaml
```

---

## 4. Create ArgoCD Applications

Register repository.

Create Application resources.

Sync applications.

---

## 5. Verify PostgreSQL

```bash
kubectl get pods
kubectl get pvc
```

PostgreSQL must be Running.

---

## 6. Run Database Migration

```bash
kubectl apply -f backend/k8s/migrate/postgres-migrate-job.yaml
```

Wait until completed.

---

## 7. Verify Backend

```bash
kubectl rollout status deployment/finote-backend
```

---

## 8. Verify Frontend

```bash
kubectl rollout status deployment/finote-frontend
```

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
* External Secrets / Vault
* Monitoring Stack
* GitOps Full Recovery

```
```
