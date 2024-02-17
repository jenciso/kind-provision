#!/bin/bash

if [[ ${DEBUG} = true ]]; then
  set -x
fi

echo "Configuring metallb"
export METALLB_POOL_ADDR=$(echo $CLUSTER_NETWORK | awk -F '.' '{ print $1"."$2"."$3".200-"$1"."$2"."$3".250"}')

## Install Core Applications
cd kube-apps/core-apps
helmfile apply
