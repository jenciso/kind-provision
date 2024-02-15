#!/bin/bash

kind delete cluster --name ${CLUSTER_NAME}
docker rm -f demo-registry-proxy
docker rm -f demo-kind-registry
docker network rm ${CLUSTER_NAME}
