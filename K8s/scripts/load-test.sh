#!/bin/bash

# Kubernetes Java App - Load Test Script
# This script generates load to test HPA (Horizontal Pod Autoscaler)

echo "======================================"
echo "Starting Load Test for HPA"
echo "======================================"
echo ""

echo "This will generate load on the application to trigger autoscaling."
echo "Watch HPA status in another terminal with: kubectl get hpa -w"
echo ""

echo "Creating load generator pod..."
kubectl run load-generator \
  --image=busybox:1.36 \
  --restart=Never \
  --rm \
  -i \
  -- /bin/sh -c "while true; do wget -q -O- http://my-java-app-service:8080/api/Hello/World; done"

echo ""
echo "Load test stopped."
