#!/bin/bash

# Kubernetes Java App - Complete Deployment Script
# This script deploys all Kubernetes resources in the correct order

set -e  # Exit on any error

echo "======================================"
echo "Starting Kubernetes Deployment"
echo "======================================"
echo ""

# Check if minikube is running
echo "1. Checking Minikube status..."
if ! minikube status &> /dev/null; then
    echo "❌ Minikube is not running!"
    echo "Please start Minikube first: minikube start --driver=docker --cpus=4 --memory=4096"
    exit 1
fi
echo "✅ Minikube is running"
echo ""

# Check if kubectl is available
echo "2. Checking kubectl..."
if ! kubectl version --client &> /dev/null; then
    echo "❌ kubectl is not installed!"
    exit 1
fi
echo "✅ kubectl is available"
echo ""

# Enable required addons
echo "3. Enabling Minikube addons..."
minikube addons enable ingress
minikube addons enable metrics-server
echo "✅ Addons enabled"
echo ""

# Build Docker image
echo "4. Building Docker image..."
cd "$(dirname "$0")/.."
eval $(minikube docker-env)
docker build -t my-java-app:1.3 .
echo "✅ Docker image built"
echo ""

# Deploy resources in correct order
echo "5. Deploying Namespaces..."
kubectl apply -f K8s/01-namespace/
kubectl get namespaces | grep -E "dev|prod|staging" || true
echo ""

echo "6. Deploying ConfigMaps and Secrets..."
kubectl apply -f K8s/02-config/
kubectl get configmaps,secrets | grep my-java-app || true
echo ""

echo "7. Deploying Storage (PV/PVC)..."
kubectl apply -f K8s/03-storage/
kubectl get pv,pvc
echo ""

echo "8. Deploying RBAC (ServiceAccount, Role, RoleBinding)..."
kubectl apply -f K8s/07-rbac/
kubectl get sa,role,rolebinding | grep my-java-app || true
echo ""

echo "9. Deploying Application (Deployment & Service)..."
kubectl apply -f K8s/04-deployment/
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/my-java-app
kubectl get deployment,pods,svc | grep my-java-app || true
echo ""

echo "10. Deploying HPA (Horizontal Pod Autoscaler)..."
kubectl apply -f K8s/06-autoscaling/
kubectl get hpa
echo ""

echo "11. Deploying Ingress..."
kubectl apply -f K8s/05-networking/ingress.yaml
kubectl get ingress
echo ""

echo "12. Deploying Jobs and CronJobs..."
kubectl apply -f K8s/07-jobs/
kubectl get jobs,cronjobs
echo ""

echo "13. Deploying Network Policies (optional)..."
kubectl apply -f K8s/08-network-policy/ || echo "⚠️  Network policies not applied (may not be supported)"
echo ""

echo "======================================"
echo "✅ Deployment Complete!"
echo "======================================"
echo ""

echo "📊 Cluster Status:"
kubectl get all
echo ""

echo "🌐 Access the application:"
echo "   Via NodePort:     minikube service my-java-app-service"
echo "   Via Port Forward: kubectl port-forward svc/my-java-app-service 8080:8080"
echo ""

echo "🧪 Test endpoints:"
echo "   curl http://localhost:8080/api/Hello/World"
echo "   curl http://localhost:8080/api/Hello/info"
echo "   curl http://localhost:8080/actuator/health"
echo ""

echo "📝 View logs:"
echo "   kubectl logs -f deployment/my-java-app"
echo ""

echo "🎯 Dashboard:"
echo "   minikube dashboard"
