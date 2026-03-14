#!/bin/bash

# Kubernetes Java App - Cleanup Script
# This script removes all deployed resources

set -e

echo "======================================"
echo "Cleaning up Kubernetes resources"
echo "======================================"
echo ""

echo "Deleting Jobs and CronJobs..."
kubectl delete -f K8s/07-jobs/ --ignore-not-found=true

echo "Deleting Network Policies..."
kubectl delete -f K8s/08-network-policy/ --ignore-not-found=true

echo "Deleting Ingress..."
kubectl delete -f K8s/05-networking/ --ignore-not-found=true

echo "Deleting HPA..."
kubectl delete -f K8s/06-autoscaling/ --ignore-not-found=true

echo "Deleting Application (Deployment & Service)..."
kubectl delete -f K8s/04-deployment/ --ignore-not-found=true

echo "Deleting RBAC..."
kubectl delete -f K8s/07-rbac/ --ignore-not-found=true

echo "Deleting Storage..."
kubectl delete -f K8s/03-storage/ --ignore-not-found=true

echo "Deleting ConfigMaps and Secrets..."
kubectl delete -f K8s/02-config/ --ignore-not-found=true

echo "Deleting Namespaces..."
kubectl delete -f K8s/01-namespace/ --ignore-not-found=true

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "To completely remove Minikube cluster:"
echo "   minikube delete"
