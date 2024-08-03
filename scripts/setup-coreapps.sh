#!/bin/bash

if [[ ${DEBUG} = true ]]; then
  set -x
fi

echo "Configuring metallb"
POOL=$(echo "$CLUSTER_NETWORK" | awk -F '.' '{ print $1"."$2"."$3".200-"$1"."$2"."$3".250"}')
export METALLB_POOL_ADDR=$POOL

## Install Core Applications
cd kube-apps/core-apps || exit
helmfile apply
