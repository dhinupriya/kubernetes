# Kubernetes apply order

Apply resources in this order (create namespaces first, then config, then app, then policies).

## 1. Namespaces
```bash
kubectl apply -f K8s/01-namespace/dev-namespace.yaml
kubectl apply -f K8s/01-namespace/prod-namespace.yaml
# If using staging:
kubectl apply -f K8s/01-namespace/staging-namespace.yaml
```

## 2. Policies (ResourceQuota + LimitRange) – optional
```bash
kubectl apply -f K8s/06-policies/resource-quota-dev.yaml
kubectl apply -f K8s/06-policies/limit-range-dev.yaml
kubectl apply -f K8s/06-policies/resource-quota-prod.yaml
kubectl apply -f K8s/06-policies/limit-range-prod.yaml
```

## 3. Deploy with Kustomize (dev or prod)
Deploys ConfigMap, Secret, Deployment, Service, and RBAC into the chosen namespace.
```bash
# Dev (1 replica)
kubectl apply -k K8s/overlays/dev

# Prod (3 replicas)
kubectl apply -k K8s/overlays/prod
```

## 4. Or deploy without Kustomize (manual)
```bash
kubectl apply -f K8s/02-config/configmap.yaml -n dev
kubectl apply -f K8s/02-config/secret.yaml -n dev
kubectl apply -f K8s/07-rbac/serviceaccount.yaml -n dev
kubectl apply -f K8s/07-rbac/role.yaml -n dev
kubectl apply -f K8s/07-rbac/rolebinding-dev.yaml
kubectl apply -f K8s/04-deployment/deployment.yaml -n dev
kubectl apply -f K8s/04-deployment/service.yaml -n dev
```

## 5. Network policies – optional
```bash
kubectl apply -f K8s/08-network-policy/allow-ingress-to-app-dev.yaml
kubectl apply -f K8s/08-network-policy/allow-ingress-to-app-prod.yaml
```

## 6. Ingress – optional (requires Ingress controller)
```bash
kubectl apply -f K8s/05-networking/ingress.yaml -n dev
```

## Verify
```bash
kubectl get all -n dev
kubectl get quota,limitrange -n dev
kubectl get sa,role,rolebinding -n dev
kubectl get networkpolicies -n dev
```
