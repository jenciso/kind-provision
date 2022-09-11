# INSTALL

## Pre-Install

To create a new cluster you need to create previously and `.env` file before. Take a look at `.env.sample` file

```
cp .env.sample .env && vim .env
```

Load your environment variables modified
```
cat .env
export $(cat .env | xargs)
```

## Setup a cluster via Kind


Setup a custom network configuration
```
export CLUSTER_GATEWAY=$(echo $CLUSTER_NETWORK | awk -F '.' '{ print $1"."$2"."$3".1"}')
docker network create --subnet $CLUSTER_NETWORK --gateway $CLUSTER_GATEWAY $CLUSTER_NAME || echo "Already exist $CLUSTER_NETWORK network"
export KIND_EXPERIMENTAL_DOCKER_NETWORK=$CLUSTER_NAME
```

Create a Kubernetes cluster specifying a kuberntes version

```
kind create cluster --name $CLUSTER_NAME --image "kindest/node:v1.23.10"
```

## Setup and Configuration

### MetalLB

```
export METALLB_POOL_ADDR=$(echo $CLUSTER_NETWORK | awk -F '.' '{ print $1"."$2"."$3".200-"$1"."$2"."$3".250"}')
```
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
envsubst < templates/metallb-config.yaml | kubectl apply -f -
```

### External DNS

```
envsubst < templates/external-dns.yaml | kubectl apply -f -
```

### Setup Ingress with nginx as default ingressClass

```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN}

kubectl annotate ingressClass nginx ingressclass.kubernetes.io/is-default-class=true
```

### CertManager

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
```
```
envsubst < templates/secret-cloudflare.yaml | kubectl apply -f -
kubectl wait -n cert-manager --for=condition=ready pod --selector=app.kubernetes.io/component=webhook --timeout=90s

envsubst < templates/cluster-issuer.yaml | kubectl apply -f -
envsubst < templates/certificate-wildcard.yaml | kubectl apply -f -
```

### Update Ingress Nginx to use wildcard certificate 

If you don't want to use kube-replicator, you can use the extraArgs configuration for your nginx controller
```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN} \
  --set controller.extraArgs."default-ssl-certificate"=cert-manager/cert-wildcard
```

### Kube replicator (Optional)

```
kubectl apply -f https://raw.githubusercontent.com/mittwald/kubernetes-replicator/master/deploy/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/mittwald/kubernetes-replicator/master/deploy/deployment.yaml
```
```
until kubectl get secret -n cert-manager cert-wildcard ; do echo  "Waiting for the secret ..."; sleep 3; done

kubectl patch secret -n cert-manager cert-wildcard --type='json' \
  -p='[{"op": "add", "path": "/metadata/annotations/replicator.v1.mittwald.de~1replicate-to", "value":"*"}]'
```

### Metrics server (Optional)

```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server --namespace kube-system metrics-server/metrics-server \
  --set args={--kubelet-insecure-tls}
```

### Kubernetes dashboard (Optional)

Install 
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
```

Create a user with privileges to login cluster dashboard
```
kubectl apply -f templates/kubernetes-dashboard-user.yaml
```
Get user token 
```
kubectl -n kubernetes-dashboard get secret \
  $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") \
  -o go-template="{{.data.token | base64decode}}" | pbcopy
```

Open in your browser: 

```
kube-proxy
```

* http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy

### Prometheus

This operator creates metrics-server into `prometheus` namespace. So, if you installed it before, uninstall it

```
helm delete metrics-server -n kube-system
``` 

We will use [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) to have a complete o11y stack

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus --create-namespace --namespace prometheus prometheus-community/kube-prometheus-stack
```

To discover others ServiceMonitor in different namespace:

```
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
--namespace prometheus  \
--set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
--set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

Creating ingress entries:

```
envsubst < templates/prometheus-ingress.yaml | kubectl apply -f -
envsubst < templates/grafana-ingress.yaml | kubectl apply -f -
envsubst < templates/alertmanager-ingress.yaml | kubectl apply -f -
```

To enable metrics exporter in ingress-nginx:

```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN} \
  --set controller.extraArgs."default-ssl-certificate"=cert-manager/cert-wildcard \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.enabled=true \
  --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus"
```

> Source: https://kubernetes.github.io/ingress-nginx/user-guide/monitoring/#before-you-begin
