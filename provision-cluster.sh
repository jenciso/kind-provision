#!/bin/bash

if test -f ".env" ; then
    echo "Exporting variables from configuration file"
    set -o allexport
    source .env
    set +o allexport
else
    echo "Error exporting env vars"
    exit 1
fi

## Setting cluster 

echo "Creating cluster"
CLUSTER_GATEWAY=$(echo $CLUSTER_NETWORK | awk -F '.' '{ print $1"."$2"."$3".1"}')
(docker network list | grep -w $CLUSTER_NAME) && \
  echo "Already exist $CLUSTER_NETWORK network. Please delete the network first" && exit 1

docker network create --subnet $CLUSTER_NETWORK --gateway $CLUSTER_GATEWAY $CLUSTER_NAME
echo "cluster_gateway=$CLUSTER_GATEWAY"
echo "cluster_network=$CLUSTER_NETWORK"
export KIND_EXPERIMENTAL_DOCKER_NETWORK=$CLUSTER_NAME
kind create cluster --name $CLUSTER_NAME --image "kindest/node:v$KUBE_VERSION" --wait=30s

### Metallb
echo "Configuring metallb"
export METALLB_POOL_ADDR=$(echo $CLUSTER_NETWORK | awk -F '.' '{ print $1"."$2"."$3".200-"$1"."$2"."$3".250"}')
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.11/config/manifests/metallb-native.yaml --wait=true
sleep 3
kubectl wait -n metallb-system --for=condition=ready pod --selector=app=metallb,component=controller --timeout=90s \
  && envsubst < templates/metallb-config.yaml | kubectl apply -f -

### External DNS
echo "Setting up external dns"
envsubst < templates/external-dns.yaml | kubectl apply -f -
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN} > /dev/null
kubectl annotate ingressClass nginx ingressclass.kubernetes.io/is-default-class=true

### CertManager
echo "Setting up cert-manager"
export ID_DOMAIN=$(date | md5sum | head -c 5)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml
envsubst < templates/secret-cloudflare.yaml | kubectl apply -f - --wait=true
sleep 3
kubectl wait -n cert-manager --for=condition=ready pod --selector=app.kubernetes.io/component=webhook --timeout=90s \
 &&  envsubst < templates/cluster-issuer.yaml | kubectl apply -f - \
 &&  envsubst < templates/certificate-wildcard.yaml | kubectl apply -f -

### Update Ingress Nginx to use wildcard certificate
echo "Setting up nginx ingress"
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN} \
  --set controller.extraArgs."default-ssl-certificate"=cert-manager/cert-wildcard > /dev/null

### Installing metrics-server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server --namespace kube-system metrics-server/metrics-server \
  --set args={--kubelet-insecure-tls} > /dev/null

### Kubernetes dashboard (Optional)
echo "Setting up dashboard"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl apply -f templates/kubernetes-dashboard-user.yaml

### Prometheus
echo "Installing prometheus"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm install prometheus --create-namespace --namespace prometheus prometheus-community/kube-prometheus-stack > /dev/null
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
--namespace prometheus  \
--set prometheus.prometheusSpec.enableRemoteWriteReceiver=true \
--set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
--set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false > /dev/null

envsubst < templates/prometheus-ingress.yaml | kubectl apply -f -
envsubst < templates/grafana-ingress.yaml | kubectl apply -f -
envsubst < templates/alertmanager-ingress.yaml | kubectl apply -f -

### Nginx metrics
echo "Setting ingress metrics"
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN} \
  --set controller.extraArgs."default-ssl-certificate"=cert-manager/cert-wildcard \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.enabled=true \
  --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus" > /dev/null

### Docker disable start on system
docker update --restart=no ${CLUSTER_NAME}-control-plane
