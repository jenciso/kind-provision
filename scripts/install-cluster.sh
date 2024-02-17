#!/bin/bash

if [[ ${DEBUG} = true ]]; then
  set -x
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

KIND_CONFIG_FILE=kind-config.yaml

if [ ${CUSTOM_CNI} != kind ]; then
  KIND_CONFIG_FILE=kind-config_custom-cni.yaml
fi

kind create cluster --name $CLUSTER_NAME --image "kindest/node:v$KUBE_VERSION" --wait=60s --config=scripts/${KIND_CONFIG_FILE}

## Post-install

### Disabling cluster to auto-start
for DOCKER_ID in $(docker ps -a --no-trunc --filter name=^${CLUSTER_NAME}- -q); do
  docker update --restart=no $DOCKER_ID
done
