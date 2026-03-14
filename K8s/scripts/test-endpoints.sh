#!/bin/bash

# Kubernetes Java App - Test Endpoints Script

echo "======================================"
echo "Testing Application Endpoints"
echo "======================================"
echo ""

# Get service URL
SERVICE_URL="http://localhost:8080"

echo "🧪 Testing endpoints at: $SERVICE_URL"
echo ""

echo "1. Testing /api/Hello/World..."
curl -s $SERVICE_URL/api/Hello/World
echo ""
echo ""

echo "2. Testing /api/Hello/info..."
curl -s $SERVICE_URL/api/Hello/info | jq '.' 2>/dev/null || curl -s $SERVICE_URL/api/Hello/info
echo ""
echo ""

echo "3. Testing /api/Hello/env..."
curl -s $SERVICE_URL/api/Hello/env | jq '.' 2>/dev/null || curl -s $SERVICE_URL/api/Hello/env
echo ""
echo ""

echo "4. Testing /actuator/health..."
curl -s $SERVICE_URL/actuator/health | jq '.' 2>/dev/null || curl -s $SERVICE_URL/actuator/health
echo ""
echo ""

echo "5. Testing /actuator/health/liveness..."
curl -s $SERVICE_URL/actuator/health/liveness | jq '.' 2>/dev/null || curl -s $SERVICE_URL/actuator/health/liveness
echo ""
echo ""

echo "6. Testing /actuator/health/readiness..."
curl -s $SERVICE_URL/actuator/health/readiness | jq '.' 2>/dev/null || curl -s $SERVICE_URL/actuator/health/readiness
echo ""
echo ""

echo "======================================"
echo "✅ Testing complete!"
echo "======================================"
