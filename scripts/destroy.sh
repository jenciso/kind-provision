#!/bin/bash

if test -f "./.env" ; then
    echo "Exporting variables from configuration file"
    set -o allexport
    source ./.env
    set +o allexport
else
    echo "Error exporting env vars"
    exit 1
fi

kind delete cluster --name ${CLUSTER_NAME}
docker network rm ${CLUSTER_NAME}
