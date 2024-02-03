#!/bin/bash

## Reading the .env file with configuration settings
if test -f "./.env" ; then
    echo "Exporting variables from configuration file"
    set -o allexport; source ./.env; set +o allexport
else
    echo "Error exporting env vars"; exit 1
fi


## Provisioning cluster 
echo "Creating cluster"
CLUSTER_GATEWAY=$(echo $CLUSTER_NETWORK | awk -F '.' '{ print $1"."$2"."$3".1"}')
(docker network list | grep -w $CLUSTER_NAME) && \
  echo "Network $CLUSTER_NETWORK already exists" && exit 1

docker network create --subnet $CLUSTER_NETWORK --gateway $CLUSTER_GATEWAY $CLUSTER_NAME
echo "cluster_gateway=$CLUSTER_GATEWAY"
echo "cluster_network=$CLUSTER_NETWORK"
export KIND_EXPERIMENTAL_DOCKER_NETWORK=$CLUSTER_NAME
kind create cluster --name $CLUSTER_NAME --image "kindest/node:v$KUBE_VERSION" --wait=30s

## Disabling cluster to auto-start
docker update --restart=no ${CLUSTER_NAME}-control-plane
