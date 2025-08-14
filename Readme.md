# GitOps with ArgoCD on Amazon EKS

This repository demonstrates how to deploy applications to an **Amazon EKS** cluster using **ArgoCD** and GitOps principles.

## Overview

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It automatically syncs your Kubernetes manifests from a Git repository to your cluster, ensuring your cluster state always matches your Git state.

In this project, we:

- Provisioned an **EKS cluster** on AWS.
- Installed **ArgoCD** into the cluster.
- Configured ArgoCD to track this repository.
- Deployed a containerized social media app via GitOps.

---

## 🚀 Steps to Deploy

### 1. Provision EKS Cluster
- Created an EKS cluster using Terraform or AWS CLI.
- Configured `kubectl` to connect to the cluster.

### 2. Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Expose ArgoCD Server
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get svc argocd-server -n argocd

 Access ArgoCD UI
 ssh -i terraform-key.pem -L 8080:192.168.49.2:443 ubuntu@<EC2-Public-IP>

Login to ArgoCD
kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d

Create an ArgoCD Application

Apply it:


kubectl apply -f application.yaml

Sync & Deploy
In ArgoCD UI, click Sync.
App will be deployed to the EKS cluster automatically.
