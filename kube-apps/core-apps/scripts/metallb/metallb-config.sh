#!/bin/bash

export METALLB_POOL_ADDR=$1

exho "Setting up metallb with custom ip pool address"
kubectl wait -n metallb-system --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s \
  && envsubst < ./scripts/metallb/metallb-config.yaml | kubectl apply -f -
