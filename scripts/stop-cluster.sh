#!/bin/bash

if [[ ${DEBUG} = true ]]; then
  set -x
fi

## Stopping cluster

for DOCKER_ID in $(docker ps -a --no-trunc --filter name=^"${CLUSTER_NAME}"- -q); do
 docker stop "$DOCKER_ID"
done
