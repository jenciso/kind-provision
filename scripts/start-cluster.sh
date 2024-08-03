#!/bin/bash

if [[ ${DEBUG} = true ]]; then
  set -x
fi

## Starting cluster

for DOCKER_ID in $(docker ps -a --no-trunc --filter name=^"${CLUSTER_NAME}"- -q); do
 docker start "$DOCKER_ID"
done
