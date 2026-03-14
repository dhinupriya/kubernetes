# Kubernetes Deployment Guide - Step by Step

This guide walks you through deploying your Java application to Kubernetes step by step.

## 📋 Prerequisites Check

```bash
# Check all tools are installed
docker --version
minikube version
kubectl version --client
java -version
mvn -version
```

## 🚀 Quick Deployment (Automated)

If you want to deploy everything automatically:

```bash
# Start Minikube first
minikube start --driver=docker --cpus=4 --memory=4096

# Run the deployment script
./scripts/deploy-all.sh
```

That's it! The script handles everything.

---

## 📝 Manual Step-by-Step Deployment

If you want to understand each step, follow this manual process:

### Step 1: Start Minikube

```bash
# Start Minikube cluster
minikube start --driver=docker --cpus=4 --memory=4096

# Verify it's running
minikube status

# Check cluster info
kubectl cluster-info
```

**Expected output:**
```
✅ minikube: Running
✅ kubectl configured
```

---

### Step 2: Build Java Application

```bash
# Navigate to project root
cd /Users/dhinupriya/Documents/Kubernetes

# Build JAR file
mvn clean package -DskipTests

# Verify JAR is created
ls -lh target/*.jar
```

**Expected output:** `demo-0.0.1-SNAPSHOT.jar` in `target/` folder

---

### Step 3: Build Docker Image

```bash
# Point to Minikube's Docker daemon (IMPORTANT!)
eval $(minikube docker-env)

# Build Docker image
docker build -t my-java-app:1.3 .

# Verify image is built
docker images | grep my-java-app
```

**Expected output:**
```
my-java-app   1.3   <image-id>   <time>   <size>
```

---

### Step 4: Enable Minikube Addons

```bash
# Enable Ingress controller
minikube addons enable ingress

# Enable Metrics Server (for HPA)
minikube addons enable metrics-server

# Verify addons
minikube addons list | grep -E "ingress|metrics-server"
```

**Expected output:**
```
✅ ingress: enabled
✅ metrics-server: enabled
```

---

### Step 5: Deploy Namespaces

```bash
# Create namespaces
kubectl apply -f K8s/01-namespace/

# Verify
kubectl get namespaces | grep -E "dev|prod|staging"
```

**Expected output:**
```
dev       Active   <time>
prod      Active   <time>
staging   Active   <time>
```

---

### Step 6: Deploy ConfigMaps and Secrets

```bash
# Apply configuration
kubectl apply -f K8s/02-config/

# Verify ConfigMap
kubectl get configmap my-java-app-config
kubectl describe configmap my-java-app-config

# Verify Secret (values are hidden)
kubectl get secret my-java-app-secret
kubectl describe secret my-java-app-secret
```

**Expected output:**
```
✅ ConfigMap: my-java-app-config created
✅ Secret: my-java-app-secret created
```

---

### Step 7: Deploy Storage (PV/PVC)

```bash
# Create storage resources
kubectl apply -f K8s/03-storage/

# Verify
kubectl get pv,pvc
```

**Expected output:**
```
persistentvolume/my-java-app-pv       1Gi    Available
persistentvolumeclaim/my-java-app-pvc   Pending (or Bound)
```

---

### Step 8: Deploy RBAC

```bash
# Create ServiceAccount, Role, RoleBinding
kubectl apply -f K8s/07-rbac/

# Verify
kubectl get serviceaccount my-java-app-sa
kubectl get role my-java-app-role
kubectl get rolebinding my-java-app-rolebinding
```

**Expected output:**
```
✅ ServiceAccount created
✅ Role created
✅ RoleBinding created
```

---

### Step 9: Deploy Application

```bash
# Deploy the app and service
kubectl apply -f K8s/04-deployment/

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=300s deployment/my-java-app

# Check status
kubectl get deployment my-java-app
kubectl get pods
kubectl get service my-java-app-service
```

**Expected output:**
```
NAME          READY   UP-TO-DATE   AVAILABLE
my-java-app   2/2     2            2

NAME                          READY   STATUS    RESTARTS
my-java-app-xxxxxxxxx-xxxxx   1/1     Running   0
my-java-app-xxxxxxxxx-xxxxx   1/1     Running   0
```

**Check pod logs:**
```bash
kubectl logs -f deployment/my-java-app
```

---

### Step 10: Deploy HPA (Horizontal Pod Autoscaler)

```bash
# Create HPA
kubectl apply -f K8s/06-autoscaling/

# Verify HPA
kubectl get hpa

# Describe HPA (see current metrics)
kubectl describe hpa my-java-app-hpa
```

**Expected output:**
```
NAME              REFERENCE                TARGETS         MINPODS   MAXPODS   REPLICAS
my-java-app-hpa   Deployment/my-java-app   <unknown>/70%   2         10        2
```

**Note:** Metrics may show `<unknown>` initially. Wait 1-2 minutes for metrics to populate.

---

### Step 11: Deploy Ingress

```bash
# Create Ingress resource
kubectl apply -f K8s/05-networking/ingress.yaml

# Verify
kubectl get ingress my-java-app-ingress

# Check ingress details
kubectl describe ingress my-java-app-ingress
```

**Expected output:**
```
NAME                  CLASS   HOSTS                ADDRESS        PORTS
my-java-app-ingress   nginx   my-java-app.local   <minikube-ip>   80
```

---

### Step 12: Deploy Jobs and CronJobs

```bash
# Create Job and CronJob
kubectl apply -f K8s/07-jobs/

# Verify
kubectl get jobs
kubectl get cronjobs

# Check job logs
kubectl logs job/init-db-job
```

**Expected output:**
```
✅ Job: init-db-job (Completed)
✅ CronJob: cleanup-cronjob (scheduled)
```

---

### Step 13: Deploy Network Policies (Optional)

```bash
# Apply network policies
kubectl apply -f K8s/08-network-policy/

# Verify
kubectl get networkpolicy
```

---

## 🧪 Testing Your Deployment

### Option 1: Port Forward (Recommended)

```bash
# Forward service port to localhost
kubectl port-forward svc/my-java-app-service 8080:8080
```

**In another terminal, test endpoints:**
```bash
# Or use the test script
./scripts/test-endpoints.sh

# Manual testing
curl http://localhost:8080/api/Hello/World
curl http://localhost:8080/api/Hello/info
curl http://localhost:8080/actuator/health
```

### Option 2: NodePort

```bash
# Get service URL
minikube service my-java-app-service --url

# Or open in browser
minikube service my-java-app-service
```

---

## 🔍 Verification Commands

```bash
# Check all resources
kubectl get all

# Check pods status
kubectl get pods -w

# Check logs
kubectl logs -f deployment/my-java-app

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check HPA metrics
kubectl top nodes
kubectl top pods
kubectl get hpa -w

# Check configmap values
kubectl get configmap my-java-app-config -o yaml

# Check secret (base64 encoded)
kubectl get secret my-java-app-secret -o yaml
```

---

## 🎯 Test HPA Auto-Scaling

```bash
# Run load test in one terminal
./scripts/load-test.sh

# Watch HPA in another terminal
kubectl get hpa -w

# Watch pods scaling
kubectl get pods -w
```

**Expected:** Pods should scale from 2 → up to 10 based on CPU load.

---

## 🎨 View Kubernetes Dashboard

```bash
minikube dashboard
```

This opens the Kubernetes dashboard in your browser where you can see:
- All pods, services, deployments
- Resource usage graphs
- Logs
- Events

---

## 🧹 Cleanup

### Remove all resources:

```bash
./scripts/cleanup.sh
```

### Or manually:

```bash
kubectl delete -f K8s/07-jobs/
kubectl delete -f K8s/08-network-policy/
kubectl delete -f K8s/05-networking/
kubectl delete -f K8s/06-autoscaling/
kubectl delete -f K8s/04-deployment/
kubectl delete -f K8s/07-rbac/
kubectl delete -f K8s/03-storage/
kubectl delete -f K8s/02-config/
kubectl delete -f K8s/01-namespace/
```

### Stop Minikube:

```bash
minikube stop
```

### Delete Minikube cluster:

```bash
minikube delete
```

---

## 🐛 Troubleshooting

### Pod is CrashLoopBackOff

```bash
# Check logs
kubectl logs <pod-name>

# Check events
kubectl describe pod <pod-name>

# Common fix: Restart
kubectl rollout restart deployment/my-java-app
```

### Image not found

```bash
# Make sure you're using Minikube's Docker
eval $(minikube docker-env)

# Rebuild image
docker build -t my-java-app:1.3 .

# Restart deployment
kubectl rollout restart deployment/my-java-app
```

### Service not accessible

```bash
# Check service endpoints
kubectl get endpoints my-java-app-service

# Port forward directly to pod
kubectl port-forward <pod-name> 8080:8080
```

### HPA not working

```bash
# Check metrics server
kubectl top nodes
kubectl top pods

# If not working, restart metrics server
minikube addons disable metrics-server
minikube addons enable metrics-server
```

---

## 📊 What You've Deployed

✅ **Core Kubernetes Concepts**
- Pods, Deployments, Services, Namespaces

✅ **Configuration Management**
- ConfigMaps, Secrets, Environment Variables

✅ **Observability**
- Liveness Probes, Readiness Probes, Logging

✅ **Scaling & Resources**
- Resource Limits/Requests, HPA

✅ **Networking**
- NodePort Service, Ingress

✅ **Storage**
- PersistentVolumes, PersistentVolumeClaims

✅ **Security**
- RBAC (ServiceAccount, Role, RoleBinding)

✅ **Batch Processing**
- Jobs, CronJobs

✅ **Network Security**
- Network Policies

---

## 🎓 CKAD Skills Demonstrated

This project demonstrates all key CKAD exam topics:
1. ✅ Core Concepts (13%)
2. ✅ Configuration (18%)
3. ✅ Multi-Container Pods (10%)
4. ✅ Observability (18%)
5. ✅ Pod Design (20%)
6. ✅ Services & Networking (13%)
7. ✅ State Persistence (8%)

**This is interview-ready proof of Kubernetes expertise!** 🚀
