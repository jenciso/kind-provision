#!/bin/bash

export METALLB_POOL_ADDR=$1

echo "Setting up metallb with custom ip pool address"

until kubectl wait -n metallb-system --for=condition=ready pod --selector=app.kubernetes.io/component=controller
  do echo "Waiting for metallb controller..."; sleep 2
done

envsubst < ./scripts/metallb/metallb-config.yaml | kubectl apply -f -
