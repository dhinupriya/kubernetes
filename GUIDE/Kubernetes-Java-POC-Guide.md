# Kubernetes POC Guide for Java Applications

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Local Kubernetes](#setup-local-kubernetes)
- [Create Java Application](#create-java-application)
- [Containerize with Docker](#containerize-with-docker)
- [Deploy to Kubernetes](#deploy-to-kubernetes)
- [Test Kubernetes Features](#test-kubernetes-features)
- [Troubleshooting](#troubleshooting)
- [Quick Commands Reference](#quick-commands-reference)
- [Next Steps](#next-steps)

---

## Overview

This guide walks you through creating a Proof of Concept (POC) for deploying a Java application on Kubernetes. You'll learn:
- How to set up a local Kubernetes cluster
- How to containerize your Java JAR file
- How to deploy and manage your application in Kubernetes
- Core Kubernetes concepts through hands-on practice

**Time Required:** 1-2 hours  
**Difficulty:** Beginner to Intermediate

---

## Prerequisites

### Required Software
1. **Docker Desktop** - Provides Docker and optionally Kubernetes
2. **kubectl** - Kubernetes command-line tool
3. **Minikube** - Local Kubernetes cluster (if not using Docker Desktop Kubernetes)
4. **Java JDK** - Version 11 or higher
5. **Maven or Gradle** - Build tool for Java

### Installation Commands (macOS)

```bash
# Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop

# Install kubectl
brew install kubectl

# Install Minikube
brew install minikube

# Verify installations
docker --version
kubectl version --client
minikube version
java -version
mvn --version
```



## Setup Local Kubernetes

### Option 1: Using Minikube (Recommended for Learning)

```bash
# Start Minikube cluster
minikube start

# Verify cluster is running
kubectl cluster-info
kubectl get nodes

# Enable useful addons
minikube addons enable metrics-server
minikube addons enable dashboard

# Open Kubernetes Dashboard (optional)
minikube dashboard
```

### Option 2: Using Docker Desktop Kubernetes

1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait for Kubernetes to start (green indicator)

```bash
# Verify it's running
kubectl cluster-info
kubectl get nodes
```

---

## Create Java Application

### Option A: Simple Spring Boot Application

If you don't have an existing Java app, create a simple one:

**1. Create project structure:**

```bash
mkdir k8s-java-poc
cd k8s-java-poc
```

**2. Create `pom.xml`:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>
    
    <groupId>com.example</groupId>
    <artifactId>k8s-demo</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

**3. Create main application class:**

`src/main/java/com/example/k8sdemo/K8sDemoApplication.java`:

```java
package com.example.k8sdemo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.net.UnknownHostException;

@SpringBootApplication
public class K8sDemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(K8sDemoApplication.class, args);
    }
}

@RestController
class HelloController {
    
    @GetMapping("/")
    public String home() {
        return "Welcome to Kubernetes POC!";
    }
    
    @GetMapping("/hello")
    public String hello() throws UnknownHostException {
        String hostname = InetAddress.getLocalHost().getHostName();
        return "Hello from Kubernetes! Pod: " + hostname;
    }
    
    @GetMapping("/info")
    public AppInfo info() throws UnknownHostException {
        return new AppInfo(
            InetAddress.getLocalHost().getHostName(),
            System.getenv().getOrDefault("POD_NAME", "unknown"),
            System.getenv().getOrDefault("POD_NAMESPACE", "default"),
            "1.0.0"
        );
    }
}

record AppInfo(String hostname, String podName, String namespace, String version) {}
```

**4. Create `application.properties`:**

`src/main/resources/application.properties`:

```properties
server.port=8080
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
```

**5. Build the application:**

```bash
mvn clean package

# Your JAR will be created at:
# target/k8s-demo-1.0.0.jar
```

### Option B: Use Your Existing JAR

If you already have a Java application:
- Make sure it exposes a health endpoint (e.g., `/health` or `/actuator/health`)
- Ensure it listens on a specific port (e.g., 8080)
- Note the path to your built JAR file

---

## Containerize with Docker

### Step 1: Create Dockerfile

Create a file named `Dockerfile` in your project root:

```dockerfile
# Use official OpenJDK runtime as base image
FROM eclipse-temurin:17-jre-alpine

# Set working directory
WORKDIR /app

# Copy the JAR file
COPY target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

### Step 2: Build Docker Image

**If using Minikube:**

```bash
# IMPORTANT: Point Docker to Minikube's Docker daemon
eval $(minikube docker-env)

# Build the image
docker build -t my-java-app:1.0 .

# Verify image exists
docker images | grep my-java-app
```

**If using Docker Desktop Kubernetes:**

```bash
# Build the image
docker build -t my-java-app:1.0 .

# Verify image exists
docker images | grep my-java-app
```

### Step 3: Test Docker Image Locally (Optional)

```bash
# Run container locally
docker run -p 8080:8080 my-java-app:1.0

# Test in another terminal
curl http://localhost:8080/hello

# Stop the container (Ctrl+C)
```

---

## Deploy to Kubernetes

### Step 1: Create Kubernetes Manifests

Create a file named `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-java-app
  labels:
    app: my-java-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-java-app
  template:
    metadata:
      labels:
        app: my-java-app
    spec:
      containers:
      - name: my-java-app
        image: my-java-app:1.0
        imagePullPolicy: Never  # Use local image (for Minikube/Docker Desktop)
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3

---
apiVersion: v1
kind: Service
metadata:
  name: my-java-app-service
  labels:
    app: my-java-app
spec:
  type: NodePort
  selector:
    app: my-java-app
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
    nodePort: 30080
```

### Step 2: Deploy to Kubernetes

```bash
# Apply the deployment
kubectl apply -f k8s-deployment.yaml

# Check deployment status
kubectl get deployments

# Check pods
kubectl get pods

# Check services
kubectl get services

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=my-java-app --timeout=120s
```

### Step 3: Verify Deployment

```bash
# Check pod status in detail
kubectl get pods -o wide

# Describe deployment
kubectl describe deployment my-java-app

# Check pod logs
kubectl logs -l app=my-java-app

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Step 4: Access Your Application

**If using Minikube:**

```bash
# Get Minikube IP
minikube ip

# Access via curl
curl http://$(minikube ip):30080/hello

# Or use minikube service (opens in browser)
minikube service my-java-app-service

# Or use port-forward
kubectl port-forward service/my-java-app-service 8080:8080
# Then access at http://localhost:8080
```

**If using Docker Desktop:**

```bash
# Access directly
curl http://localhost:30080/hello

# Open in browser
open http://localhost:30080

# Or use port-forward
kubectl port-forward service/my-java-app-service 8080:8080
```

---

## Test Kubernetes Features

### 1. Scaling

```bash
# Scale up to 5 replicas
kubectl scale deployment my-java-app --replicas=5

# Watch pods being created
kubectl get pods -w
# Press Ctrl+C to stop watching

# Check all running pods
kubectl get pods

# Scale back down to 2
kubectl scale deployment my-java-app --replicas=2
```

### 2. Self-Healing

```bash
# Delete a pod and watch Kubernetes recreate it
kubectl get pods
kubectl delete pod <pod-name>

# Watch the new pod being created
kubectl get pods -w
```

### 3. Rolling Updates

**Make a change to your application:**

```bash
# Update your Java code (change the message, version, etc.)
# Rebuild
mvn clean package

# Build new Docker image with version 2.0
eval $(minikube docker-env)  # If using Minikube
docker build -t my-java-app:2.0 .
```

**Update the deployment:**

```bash
# Update deployment with new image
kubectl set image deployment/my-java-app my-java-app=my-java-app:2.0

# Watch rolling update
kubectl rollout status deployment/my-java-app

# Check rollout history
kubectl rollout history deployment/my-java-app
```

### 4. Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/my-java-app

# Rollback to specific revision
kubectl rollout undo deployment/my-java-app --to-revision=1

# Check status
kubectl rollout status deployment/my-java-app
```

### 5. View Logs

```bash
# Logs from all pods
kubectl logs -l app=my-java-app

# Follow logs from specific pod
kubectl logs -f <pod-name>

# Logs from previous container instance (if crashed)
kubectl logs <pod-name> --previous

# Logs with timestamps
kubectl logs <pod-name> --timestamps

# Last 50 lines
kubectl logs <pod-name> --tail=50
```

### 6. Execute Commands in Pod

```bash
# Get shell access to pod
kubectl exec -it <pod-name> -- /bin/sh

# Inside the pod, explore:
ls -la /app
ps aux | grep java
env | grep POD
cat /app/app.jar  # (binary, but you can see it exists)
exit
```

### 7. Monitor Resources

```bash
# View resource usage (requires metrics-server)
kubectl top pods
kubectl top nodes

# Describe pod to see resource allocation
kubectl describe pod <pod-name>
```

### 8. Load Testing (Optional)

```bash
# Simple load test
for i in {1..100}; do
  curl http://$(minikube ip):30080/hello
done

# Watch different pods handling requests
kubectl logs -l app=my-java-app --tail=20
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Pods Not Starting - ImagePullBackOff

**Problem:** `kubectl get pods` shows `ImagePullBackOff` status

**Solution:**
```bash
# Make sure you're using Minikube's Docker daemon
eval $(minikube docker-env)

# Rebuild image
docker build -t my-java-app:1.0 .

# Ensure imagePullPolicy is set to Never in deployment.yaml
# imagePullPolicy: Never

# Reapply deployment
kubectl delete -f k8s-deployment.yaml
kubectl apply -f k8s-deployment.yaml
```

#### 2. Pods Crashing - CrashLoopBackOff

**Problem:** Pods keep restarting

**Diagnose:**
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# Common causes:
# - Application startup failure
# - Health check failing too early
# - Memory/CPU limits too low
```

**Solution:**
- Increase `initialDelaySeconds` in liveness probe
- Check application logs for startup errors
- Increase memory/CPU limits

#### 3. Cannot Access Application

**Problem:** Service is running but can't access it

**Diagnose:**
```bash
# Check service endpoints
kubectl get endpoints my-java-app-service

# Check if pods are ready
kubectl get pods

# Check service details
kubectl describe service my-java-app-service
```

**Solution:**
```bash
# Use port-forward as alternative
kubectl port-forward service/my-java-app-service 8080:8080
# Access at http://localhost:8080

# Or port-forward to specific pod
kubectl port-forward <pod-name> 8080:8080
```

#### 4. Pods Pending

**Problem:** Pods stuck in `Pending` state

**Diagnose:**
```bash
kubectl describe pod <pod-name>
# Look for scheduling errors
```

**Common causes:**
- Insufficient resources
- Node selector issues
- Storage provisioning problems

#### 5. Health Checks Failing

**Problem:** Pods not becoming ready

**Solution:**
```bash
# Test health endpoint directly
kubectl port-forward <pod-name> 8080:8080
curl http://localhost:8080/actuator/health

# Adjust probe settings in deployment:
initialDelaySeconds: 60  # Increase for slow startup
periodSeconds: 10
timeoutSeconds: 5
failureThreshold: 3
```

### Debug Commands

```bash
# Get detailed pod information
kubectl describe pod <pod-name>

# Get events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check logs
kubectl logs <pod-name> --tail=100

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/sh

# Check resource usage
kubectl top pods

# Get YAML of running pod
kubectl get pod <pod-name> -o yaml

# Check cluster info
kubectl cluster-info dump
```

---

## Quick Commands Reference

### Cluster Management

```bash
# Start Minikube
minikube start

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete

# Get cluster info
kubectl cluster-info
kubectl get nodes
```

### Deployment Commands

```bash
# Apply configuration
kubectl apply -f k8s-deployment.yaml

# Delete resources
kubectl delete -f k8s-deployment.yaml

# Get deployments
kubectl get deployments
kubectl get deploy -o wide

# Describe deployment
kubectl describe deployment my-java-app

# Edit deployment
kubectl edit deployment my-java-app
```

### Pod Commands

```bash
# List pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --watch

# Describe pod
kubectl describe pod <pod-name>

# Delete pod
kubectl delete pod <pod-name>

# Execute command in pod
kubectl exec <pod-name> -- <command>
kubectl exec -it <pod-name> -- /bin/sh

# Copy files to/from pod
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file
```

### Service Commands

```bash
# List services
kubectl get services
kubectl get svc

# Describe service
kubectl describe service my-java-app-service

# Access service (Minikube)
minikube service my-java-app-service

# Port forward
kubectl port-forward service/my-java-app-service 8080:8080
```

### Logs and Monitoring

```bash
# View logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>
kubectl logs <pod-name> --tail=50
kubectl logs -l app=my-java-app

# Resource usage
kubectl top pods
kubectl top nodes
```

### Scaling and Updates

```bash
# Scale deployment
kubectl scale deployment my-java-app --replicas=5

# Update image
kubectl set image deployment/my-java-app my-java-app=my-java-app:2.0

# Rollout status
kubectl rollout status deployment/my-java-app

# Rollout history
kubectl rollout history deployment/my-java-app

# Rollback
kubectl rollout undo deployment/my-java-app
```

### Debugging

```bash
# Get events
kubectl get events
kubectl get events --sort-by=.metadata.creationTimestamp

# Describe resources
kubectl describe deployment <name>
kubectl describe pod <name>
kubectl describe service <name>

# Get resource YAML
kubectl get pod <name> -o yaml
kubectl get deployment <name> -o yaml
```

---

## Next Steps

After completing this POC, explore these advanced topics:

### 1. ConfigMaps and Secrets

**ConfigMap** - Store configuration data:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  application.properties: |
    app.name=My Java App
    app.env=production
---
# Mount in deployment
volumes:
- name: config
  configMap:
    name: app-config
volumeMounts:
- name: config
  mountPath: /app/config
```

**Secrets** - Store sensitive data:

```bash
# Create secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123

# Use in deployment
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

### 2. Ingress Controller

Better alternative to NodePort for external access:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-java-app-ingress
spec:
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-java-app-service
            port:
              number: 8080
```

### 3. Persistent Volumes

For stateful applications:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### 4. Namespaces

Organize resources by environment:

```bash
# Create namespace
kubectl create namespace dev
kubectl create namespace prod

# Deploy to namespace
kubectl apply -f k8s-deployment.yaml -n dev

# Set default namespace
kubectl config set-context --current --namespace=dev
```

### 5. Helm Charts

Package and version your Kubernetes applications:

```bash
# Install Helm
brew install helm

# Create Helm chart
helm create my-java-app-chart

# Install chart
helm install my-app ./my-java-app-chart
```

### 6. Monitoring and Logging

**Prometheus & Grafana:**
```bash
# Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack
```

**ELK Stack or Loki** for centralized logging

### 7. CI/CD Integration

Integrate with:
- Jenkins
- GitLab CI/CD
- GitHub Actions
- ArgoCD (GitOps)

### 8. Production Considerations

- **Security**: RBAC, Pod Security Policies, Network Policies
- **High Availability**: Multiple replicas, Pod Disruption Budgets
- **Resource Management**: Resource quotas, Limit Ranges
- **Backup & Disaster Recovery**
- **Multi-cluster Management**

---

## Additional Resources

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot on Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)
- [Docker Documentation](https://docs.docker.com/)

### Learning Resources
- [Kubernetes Tutorials](https://kubernetes.io/docs/tutorials/)
- [Katacoda Interactive Learning](https://www.katacoda.com/courses/kubernetes)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)

### Tools
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [k9s](https://k9scli.io/) - Terminal UI for Kubernetes
- [Lens](https://k8slens.dev/) - Kubernetes IDE

---

## POC Completion Checklist

Mark these off as you complete them:

- [ ] Installed Docker, kubectl, and Minikube
- [ ] Started local Kubernetes cluster
- [ ] Created/used existing Java application
- [ ] Built Docker image
- [ ] Created Kubernetes deployment YAML
- [ ] Deployed application to Kubernetes
- [ ] Accessed application via Service
- [ ] Scaled deployment up and down
- [ ] Tested self-healing (deleted pod)
- [ ] Performed rolling update
- [ ] Rolled back deployment
- [ ] Viewed logs from pods
- [ ] Executed commands inside pod
- [ ] Monitored resource usage
- [ ] Understood pod lifecycle
- [ ] Debugged common issues

---

## Conclusion

Congratulations! You've completed a comprehensive Kubernetes POC. You now understand:

✅ How Kubernetes orchestrates containers  
✅ How to containerize Java applications  
✅ How to deploy and manage applications in Kubernetes  
✅ Core Kubernetes concepts (Pods, Deployments, Services)  
✅ How to scale, update, and monitor applications  

This POC provides a solid foundation for deploying Java applications to production Kubernetes clusters (EKS, GKE, AKS, or on-premises).

---

**Document Version:** 1.0  
**Last Updated:** January 2026  
**Author:** Kubernetes POC Guide for Java Developers
