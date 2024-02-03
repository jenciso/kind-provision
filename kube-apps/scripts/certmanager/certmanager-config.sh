#!/bin/bash

export CLUSTER_NAME=$1
export SITE_DOMAIN=$2
export CF_API_EMAIL=$3
export ID_DOMAIN=$(date | md5sum | head -c 5)

echo "Setting up cert-manager"

envsubst < ./scripts/certmanager/secret-cloudflare.yaml | kubectl apply -f - --wait=true
kubectl wait -n cert-manager --for=condition=ready pod --selector=app.kubernetes.io/component=webhook --timeout=90s \
  && envsubst < ./scripts/certmanager/certmanager-config.yaml | kubectl apply -f -
