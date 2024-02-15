#!/bin/bash

until kubectl wait -n calico-apiserver --for=condition=ready pod --selector=app.kubernetes.io/name=calico-apiserver
  do echo "Waiting for calico-apiserver..."; sleep 3
done
