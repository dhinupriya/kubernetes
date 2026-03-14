# Kubernetes Java Application POC - CKAD Level

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://www.java.com/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-6DB33F?style=for-the-badge&logo=spring&logoColor=white)](https://spring.io/projects/spring-boot)

A comprehensive Kubernetes proof-of-concept demonstrating CKAD (Certified Kubernetes Application Developer) level skills with a production-ready Spring Boot application deployment.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Detailed Setup](#detailed-setup)
- [Testing](#testing)
- [CKAD Skills Demonstrated](#ckad-skills-demonstrated)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This project showcases a complete Kubernetes deployment of a Java Spring Boot application, implementing all key concepts required for CKAD certification. It demonstrates real-world patterns including configuration management, security, autoscaling, networking, and observability.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Ingress                               │
│                 (my-java-app.local)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      Service (NodePort)                      │
│                   my-java-app-service                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
       ┌───────────────┼───────────────┐
       ▼               ▼               ▼
   ┌─────┐         ┌─────┐         ┌─────┐
   │ Pod │         │ Pod │         │ Pod │
   └─────┘         └─────┘         └─────┘
       │               │               │
       └───────────────┴───────────────┘
                       │
       ┌───────────────┴───────────────┐
       ▼                               ▼
┌─────────────┐                 ┌──────────┐
│ ConfigMap   │                 │  Secret  │
└─────────────┘                 └──────────┘
       │                               │
       └───────────────┬───────────────┘
                       ▼
              ┌─────────────────┐
              │       HPA        │
              │  (Auto-scaling)  │
              └─────────────────┘
```

## ✨ Features

### Core Kubernetes Components
- ✅ **Deployments** - Managed pod lifecycle with rolling updates
- ✅ **Services** - NodePort service for external access
- ✅ **ConfigMaps** - Non-sensitive configuration management
- ✅ **Secrets** - Sensitive data handling
- ✅ **Namespaces** - Multi-environment support (dev, prod)

### Advanced Features
- ✅ **Health Probes** - Liveness & Readiness checks using Spring Boot Actuator
- ✅ **Resource Management** - CPU/Memory requests and limits
- ✅ **HPA** - Horizontal Pod Autoscaler for auto-scaling
- ✅ **Ingress** - HTTP routing and load balancing
- ✅ **Storage** - Persistent Volumes and Claims
- ✅ **RBAC** - ServiceAccount, Role, and RoleBinding
- ✅ **Network Policies** - Pod-to-pod communication control
- ✅ **Jobs & CronJobs** - Batch processing and scheduled tasks

### Application Features
- REST API endpoints with environment info
- Health check endpoints (`/actuator/health`)
- Configuration injection from ConfigMaps and Secrets
- Pod name and namespace exposure

## 🔧 Prerequisites

- **Docker Desktop** - Running and configured
- **Minikube** - v1.30+
- **kubectl** - v1.27+
- **Java** - JDK 21
- **Maven** - 3.6+

### Installation

```bash
# Install Minikube
brew install minikube

# Install kubectl
brew install kubectl

# Verify installations
docker --version
minikube version
kubectl version --client
java -version
mvn -version
```

## 🚀 Quick Start

### 1. Start Minikube

```bash
minikube start --driver=docker --cpus=4 --memory=4096
minikube status
```

### 2. Build Application

```bash
# Build JAR
mvn clean package -DskipTests

# Build Docker image (use Minikube's Docker daemon)
eval $(minikube docker-env)
docker build -t my-java-app:1.3 .
docker images | grep my-java-app
```

### 3. Deploy to Kubernetes

```bash
# Apply all resources
kubectl apply -f K8s/01-namespace/
kubectl apply -f K8s/02-config/
kubectl apply -f K8s/07-rbac/
kubectl apply -f K8s/04-deployment/
kubectl apply -f K8s/06-autoscaling/
kubectl apply -f K8s/03-storage/

# Verify deployment
kubectl get all
kubectl get pods -w
```

### 4. Enable Ingress

```bash
minikube addons enable ingress
minikube addons enable metrics-server
kubectl apply -f K8s/05-networking/ingress.yaml
```

### 5. Access Application

```bash
# Via NodePort
minikube service my-java-app-service

# Via Port Forward
kubectl port-forward svc/my-java-app-service 8080:8080

# Test endpoints
curl http://localhost:8080/api/Hello/World
curl http://localhost:8080/api/Hello/info
curl http://localhost:8080/actuator/health
```

## 📁 Project Structure

```
Kubernetes/
├── src/
│   └── main/
│       ├── java/com/JavaAppKubernetes/demo/
│       │   ├── KubernetesApplication.java    # Main Spring Boot app
│       │   └── Controller.java               # REST endpoints
│       └── resources/
│           └── application.properties         # App configuration
├── K8s/
│   ├── 01-namespace/
│   │   ├── dev-namespace.yaml                # Dev environment
│   │   └── prod-namespace.yaml               # Prod environment
│   ├── 02-config/
│   │   ├── configmap.yaml                    # Application config
│   │   └── secret.yaml                       # Sensitive data
│   ├── 03-storage/
│   │   ├── pv.yaml                           # Persistent Volume
│   │   └── pvc.yaml                          # Persistent Volume Claim
│   ├── 04-deployment/
│   │   ├── deployment.yaml                   # App deployment
│   │   └── service.yaml                      # NodePort service
│   ├── 05-networking/
│   │   └── ingress.yaml                      # HTTP routing
│   ├── 06-autoscaling/
│   │   └── hpa.yaml                          # Horizontal Pod Autoscaler
│   └── 08-network-policy/
│       ├── allow-ingress-to-app-dev.yaml     # Dev network policy
│       └── allow-ingress-to-app-prod.yaml    # Prod network policy
├── Dockerfile                                 # Container image definition
├── pom.xml                                    # Maven dependencies
└── README.md                                  # This file
```

## 📖 Detailed Setup

### Building the Application

```bash
# Clean and build
mvn clean package

# The JAR will be at: target/demo-0.0.1-SNAPSHOT.jar
```

### Docker Image Creation

```bash
# Point to Minikube's Docker (important!)
eval $(minikube docker-env)

# Build image
docker build -t my-java-app:1.3 .

# Verify
docker images | grep my-java-app
```

### Kubernetes Deployment Steps

#### Step 1: Create Namespaces
```bash
kubectl apply -f K8s/01-namespace/
kubectl get namespaces
```

#### Step 2: ConfigMaps and Secrets
```bash
kubectl apply -f K8s/02-config/
kubectl get configmap my-java-app-config -o yaml
kubectl get secret my-java-app-secret
```

#### Step 3: RBAC
```bash
kubectl apply -f K8s/07-rbac/
kubectl get sa,role,rolebinding
```

#### Step 4: Storage
```bash
kubectl apply -f K8s/03-storage/
kubectl get pv,pvc
```

#### Step 5: Application Deployment
```bash
kubectl apply -f K8s/04-deployment/
kubectl get deployment,pods,svc
```

#### Step 6: Autoscaling
```bash
minikube addons enable metrics-server
kubectl apply -f K8s/06-autoscaling/
kubectl get hpa
```

#### Step 7: Ingress
```bash
minikube addons enable ingress
kubectl apply -f K8s/05-networking/
kubectl get ingress
```

#### Step 8: Jobs
```bash
kubectl apply -f K8s/07-jobs/
kubectl get jobs,cronjobs
```

#### Step 9: Network Policies (Optional)
```bash
kubectl apply -f K8s/08-network-policy/
kubectl get networkpolicy
```

## 🧪 Testing

### Endpoint Testing

```bash
# Hello World endpoint
curl http://localhost:8080/api/Hello/World

# App info (shows pod, namespace, config)
curl http://localhost:8080/api/Hello/info

# Environment variables
curl http://localhost:8080/api/Hello/env

# Health check
curl http://localhost:8080/actuator/health
```

### Kubernetes Testing

```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check HPA status
kubectl get hpa
kubectl describe hpa my-java-app-hpa

# Test scaling
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# Inside the pod:
while true; do wget -q -O- http://my-java-app-service:8080/api/Hello/World; done
```

### Rolling Updates

```bash
# Build new version
docker build -t my-java-app:1.4 .

# Update deployment
kubectl set image deployment/my-java-app my-java-app=my-java-app:1.4

# Check rollout status
kubectl rollout status deployment/my-java-app

# Rollback if needed
kubectl rollout undo deployment/my-java-app
```

## 🎓 CKAD Skills Demonstrated

| Skill | Implementation | Files |
|-------|---------------|-------|
| **Core Concepts** | Pods, Deployments, Services | `04-deployment/` |
| **Configuration** | ConfigMaps, Secrets, Environment Variables | `02-config/` |
| **Multi-Container Pods** | Init containers (planned) | `04-deployment/deployment.yaml` |
| **Observability** | Liveness/Readiness Probes, Logging | `04-deployment/deployment.yaml` |
| **Pod Design** | Labels, Selectors, Annotations | All YAML files |
| **Services & Networking** | ClusterIP, NodePort, Ingress | `04-deployment/service.yaml`, `05-networking/` |
| **State Persistence** | PersistentVolumes, PersistentVolumeClaims | `03-storage/` |
| **Security** | RBAC, ServiceAccounts, Secrets | `07-rbac/`, `02-config/secret.yaml` |
| **Resource Management** | Requests, Limits | `04-deployment/deployment.yaml` |
| **Autoscaling** | Horizontal Pod Autoscaler (HPA) | `06-autoscaling/` |
| **Network Policies** | Ingress/Egress rules | `08-network-policy/` |

## 🛠️ Troubleshooting

### Pod CrashLoopBackOff

```bash
# Check logs
kubectl logs <pod-name>

# Check events
kubectl describe pod <pod-name>

# Common fix: Restart deployment
kubectl rollout restart deployment/my-java-app
```

### Service Not Accessible

```bash
# Check service
kubectl get svc
kubectl describe svc my-java-app-service

# Check endpoints
kubectl get endpoints my-java-app-service

# Port forward for debugging
kubectl port-forward svc/my-java-app-service 8080:8080
```

### HPA Not Scaling

```bash
# Check metrics server
kubectl top nodes
kubectl top pods

# If not working:
minikube addons enable metrics-server
kubectl get deployment metrics-server -n kube-system
```

### Ingress Not Working

```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Get ingress IP
minikube ip

# Add to /etc/hosts
echo "$(minikube ip) my-java-app.local" | sudo tee -a /etc/hosts
```

### Image Pull Issues

```bash
# Ensure using Minikube's Docker
eval $(minikube docker-env)

# Rebuild image
docker build -t my-java-app:1.3 .

# Check image exists
docker images | grep my-java-app

# Update deployment
kubectl rollout restart deployment/my-java-app
```

### Java Version Mismatch

```bash
# Error: UnsupportedClassVersionError
# Fix: Ensure Dockerfile uses Java 21
FROM eclipse-temurin:21-jre-alpine

# Rebuild image
docker build -t my-java-app:1.3 .
```

## 📊 Key Commands Reference

```bash
# Cluster
minikube start
minikube status
minikube dashboard
minikube stop
minikube delete

# Deployments
kubectl apply -f <file>
kubectl get all
kubectl get pods -w
kubectl describe pod <name>
kubectl logs <pod-name>
kubectl logs -f <pod-name>

# Scaling
kubectl scale deployment my-java-app --replicas=5
kubectl autoscale deployment my-java-app --cpu-percent=50 --min=2 --max=10

# Updates
kubectl set image deployment/my-java-app my-java-app=my-java-app:1.4
kubectl rollout status deployment/my-java-app
kubectl rollout history deployment/my-java-app
kubectl rollout undo deployment/my-java-app

# Debugging
kubectl exec -it <pod-name> -- /bin/sh
kubectl port-forward <pod-name> 8080:8080
kubectl port-forward svc/my-java-app-service 8080:8080

# Cleanup
kubectl delete -f K8s/
kubectl delete all --all
```

## 🎯 Learning Outcomes

After completing this POC, you will understand:

1. **Container Orchestration** - How Kubernetes manages application lifecycle
2. **Configuration Management** - Separating config from code using ConfigMaps/Secrets
3. **Service Discovery** - How pods communicate via Services
4. **Load Balancing** - Distributing traffic across pods
5. **Auto-scaling** - Horizontal scaling based on metrics
6. **Health Monitoring** - Probes for application health
7. **Security** - RBAC for access control
8. **Storage** - Persistent data management
9. **Networking** - Ingress, Network Policies
10. **CI/CD Ready** - Production-ready deployment patterns

## 📝 License

This project is for educational purposes and demonstrates Kubernetes skills equivalent to CKAD certification.

## 👤 Author

Created as a CKAD-level proof of concept for Kubernetes deployment skills.

---

**⭐ If this helped you, please star the repository!**
