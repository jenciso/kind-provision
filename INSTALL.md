# INSTALL

## Pre-Install

Create a new cluster file with the name of your cluster. Example: cluster "apps"
```
vim cluster-apps.env
```
Load the environment variables
```
. .env
```

## Setup a cluster via Kind


Setup a custom network configuration
```
export CLUSTER_GATEWAY=$(echo $CLUSTER_NETWORK | awk -F '.' '{ print $1"."$2"."$3".1"}')
docker network create --subnet $CLUSTER_NETWORK --gateway $CLUSTER_GATEWAY $CLUSTER_NAME
export KIND_EXPERIMENTAL_DOCKER_NETWORK=$CLUSTER_NAME
```

Create a Kubernetes cluster 

```
kind create cluster --name $CLUSTER_NAME
```

## Configuration components

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

### Ingress

```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN}
```
```
envsubst < templates/ingressClass.yaml | kubectl apply -f -
```

### CertManager

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml
```
```
envsubst < templates/secret-cloudflare.yaml | kubectl apply -f -
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
  --set controller.extraArgs."--default-ssl-certificate"=cert-manager/cert-wildcard
```

### Kube replicator (Optional)

```
kubectl apply -f https://raw.githubusercontent.com/mittwald/kubernetes-replicator/master/deploy/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/mittwald/kubernetes-replicator/master/deploy/deployment.yaml
```
```
kubectl patch secret -n cert-manager cert-wildcard --type='json' \
  -p='[{"op": "add", "path": "/metadata/annotations/replicator.v1.mittwald.de~1replicate-to", "value":"*"}]'
```
