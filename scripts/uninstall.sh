#!/bin/bash

## Uninstall Applications

export METALLB_POOL_ADDR=$(echo $CLUSTER_NETWORK | awk -F '.' '{ print $1"."$2"."$3".200-"$1"."$2"."$3".250"}')
DIR=$PWD

cd $DIR/kube-apps/common-apps
helmfile destroy

cd $DIR/kube-apps/core-apps
helmfile destroy
