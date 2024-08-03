#!/bin/bash

## Uninstall Applications

POOL=$(echo "$CLUSTER_NETWORK" | awk -F '.' '{ print $1"."$2"."$3".200-"$1"."$2"."$3".250"}')
export METALLB_POOL_ADDR="$POOL"

DIR=$PWD
cd "$DIR/kube-apps/common-apps" || exit
helmfile destroy

cd "$DIR/kube-apps/core-apps" || exit
helmfile destroy
