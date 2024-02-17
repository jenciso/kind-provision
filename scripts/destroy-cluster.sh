#!/bin/bash

kind delete cluster --name ${CLUSTER_NAME}
for DOCKER_ID in $(docker ps -a --no-trunc --filter name=^${CLUSTER_NAME}- -q); do
 docker rm -f $DOCKER_ID
done
docker network rm ${CLUSTER_NAME}
