# Kubernetes Tools

Complete Kubernetes development environment with kubectl, minikube, and essential CLI tools.

## Installation

```bash
./tools-cli/kubernetes/setup.sh
```

## What Gets Installed

### Core Tools
- **kubectl** - Kubernetes command-line tool
- **minikube** - Local Kubernetes cluster for development
- **kubectx** - Switch between Kubernetes contexts easily
- **kubens** - Switch between Kubernetes namespaces easily
- **stern** - Multi-pod and container log tailing
- **k9s** - Terminal-based Kubernetes UI (if available)
- **helm** - Kubernetes package manager

## Basic Usage

### kubectl Basics

#### Cluster Information
```bash
# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get all resources
kubectl get all

# Get resources in all namespaces
kubectl get pods --all-namespaces
```

#### Working with Pods
```bash
# List pods
kubectl get pods
k get po              # Using alias

# Describe pod
kubectl describe pod <pod-name>
k describe po <pod-name>

# Get pod logs
kubectl logs <pod-name>
k logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- bash

# Port forward
kubectl port-forward <pod-name> 8080:80
```

#### Working with Deployments
```bash
# List deployments
kubectl get deployments
k get deploy

# Create deployment
kubectl create deployment nginx --image=nginx

# Scale deployment
kubectl scale deployment nginx --replicas=3

# Update deployment image
kubectl set image deployment/nginx nginx=nginx:1.19

# Roll out status
kubectl rollout status deployment/nginx

# Rollback deployment
kubectl rollout undo deployment/nginx
```

#### Working with Services
```bash
# List services
kubectl get services
k get svc

# Expose deployment
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get service endpoints
kubectl get endpoints
```

### Minikube Usage

```bash
# Start minikube
minikube start

# Start with specific resources
minikube start --cpus 4 --memory 8192

# Get minikube status
minikube status

# Access minikube dashboard
minikube dashboard

# Get minikube IP
minikube ip

# SSH into minikube
minikube ssh

# Stop minikube
minikube stop

# Delete minikube cluster
minikube delete
```

### Context and Namespace Management

#### Using kubectx
```bash
# List contexts
kubectx
kctx         # Using alias

# Switch context
kubectx minikube
kctx production

# Previous context
kubectx -

# Rename context
kubectx new-name=old-name
```

#### Using kubens
```bash
# List namespaces
kubens
kns          # Using alias

# Switch namespace
kubens default
kns kube-system

# Previous namespace
kubens -

# Create namespace
kubectl create namespace dev
```

### Helm Package Manager

```bash
# Add repository
helm repo add stable https://charts.helm.sh/stable

# Update repositories
helm repo update

# Search for charts
helm search repo nginx

# Install chart
helm install my-nginx stable/nginx

# List releases
helm list

# Upgrade release
helm upgrade my-nginx stable/nginx

# Rollback release
helm rollback my-nginx 1

# Uninstall release
helm uninstall my-nginx
```

### Log Tailing with Stern

```bash
# Tail all pods in namespace
stern .

# Tail specific deployment
stern deployment/nginx

# Tail with regex
stern "nginx-.*"

# Tail specific container
stern nginx -c nginx

# Tail with timestamps
stern nginx -t

# Tail since 1 hour ago
stern nginx --since 1h
```

## Configured Aliases

### kubectl Aliases
- `k` - kubectl
- `kgp` - kubectl get pods
- `kgs` - kubectl get services
- `kgd` - kubectl get deployments
- `kaf` - kubectl apply -f
- `kdel` - kubectl delete
- `klog` - kubectl logs
- `kexec` - kubectl exec -it
- `kport` - kubectl port-forward
- `kroll` - kubectl rollout
- `ktop` - kubectl top

### Context/Namespace Aliases
- `kctx` - kubectx
- `kns` - kubens
- `kall` - kubectl get all --all-namespaces

### Minikube Aliases
- `mk` - minikube
- `mkstart` - minikube start
- `mkstop` - minikube stop
- `mkdash` - minikube dashboard
- `mkssh` - minikube ssh
- `mkip` - minikube ip

## Configuration Files

### kubectl Config
```yaml
# ~/.kube/config
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: https://kubernetes.docker.internal:6443
  name: docker-desktop
contexts:
- context:
    cluster: docker-desktop
    user: docker-desktop
  name: docker-desktop
current-context: docker-desktop
users:
- name: docker-desktop
  user:
    client-certificate-data: <cert>
    client-key-data: <key>
```

### Helm Configuration
```bash
# ~/.config/helm/repositories.yaml
# Helm repo configuration

# ~/.cache/helm
# Helm cache directory
```

## Common Tasks

### Deploy Application
```bash
# Create deployment
kubectl create deployment myapp --image=myapp:1.0

# Expose as service
kubectl expose deployment myapp --port=8080 --type=LoadBalancer

# Scale application
kubectl scale deployment myapp --replicas=3

# Check status
kubectl get all -l app=myapp
```

### Debug Pod Issues
```bash
# Check pod status
kubectl get pod <pod-name> -o wide

# Describe pod for events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name> --previous

# Execute debug commands
kubectl exec <pod-name> -- curl localhost:8080/health

# Debug with ephemeral container
kubectl debug <pod-name> -it --image=busybox
```

### Manage Configurations
```bash
# Create config map
kubectl create configmap myconfig --from-file=config.yaml

# Create secret
kubectl create secret generic mysecret --from-literal=password=secret

# Apply configuration
kubectl apply -f manifests/

# Dry run
kubectl apply -f deployment.yaml --dry-run=client

# Generate YAML
kubectl create deployment test --image=nginx --dry-run=client -o yaml
```

### Monitor Resources
```bash
# Top nodes
kubectl top nodes

# Top pods
kubectl top pods

# Watch resources
kubectl get pods -w

# Get events
kubectl get events --sort-by='.lastTimestamp'
```

## YAML Templates

### Deployment Template
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:1.0
        ports:
        - containerPort: 8080
```

### Service Template
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### ConfigMap Template
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  config.yaml: |
    database:
      host: localhost
      port: 5432
```

## Advanced Usage

### Port Forwarding
```bash
# Forward single port
kubectl port-forward pod/myapp 8080:8080

# Forward multiple ports
kubectl port-forward pod/myapp 8080:8080 9090:9090

# Forward service
kubectl port-forward service/myapp 8080:80
```

### Resource Management
```bash
# Set resource limits
kubectl set resources deployment myapp --limits=cpu=200m,memory=512Mi

# Autoscale deployment
kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=80

# Cordon node (mark unschedulable)
kubectl cordon node1

# Drain node (evict pods)
kubectl drain node1
```

### Troubleshooting

#### Pod Won't Start
```bash
# Check events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name> --previous

# Check resource constraints
kubectl describe node
```

#### Connection Issues
```bash
# Test service DNS
kubectl run test --image=busybox -it --rm -- nslookup myservice

# Test service connectivity
kubectl run test --image=busybox -it --rm -- wget -O- myservice:80

# Check endpoints
kubectl get endpoints myservice
```

#### Storage Issues
```bash
# Check persistent volumes
kubectl get pv

# Check persistent volume claims
kubectl get pvc

# Describe PVC
kubectl describe pvc <pvc-name>
```

## Best Practices

1. **Use namespaces** to organize resources
2. **Set resource limits** for containers
3. **Use health checks** (liveness/readiness probes)
4. **Version your container images** properly
5. **Use ConfigMaps and Secrets** for configuration
6. **Apply RBAC** for security
7. **Monitor resource usage** regularly
8. **Use labels and selectors** effectively
9. **Keep YAML in version control**
10. **Test in development** before production

## Tips

1. **Enable kubectl autocompletion**:
   ```bash
   source <(kubectl completion zsh)
   ```

2. **Use kubectl explain** for documentation:
   ```bash
   kubectl explain deployment.spec
   ```

3. **Use JSONPath** for custom output:
   ```bash
   kubectl get pods -o jsonpath='{.items[*].metadata.name}'
   ```

4. **Diff before applying**:
   ```bash
   kubectl diff -f deployment.yaml
   ```

5. **Use kubectl plugins** with krew:
   ```bash
   kubectl krew install tree
   kubectl tree deployment myapp
   ```

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Helm Documentation](https://helm.sh/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)