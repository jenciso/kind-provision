#!/bin/bash

if [ "${REGISTRY_PROXY_DISABLED}" = "true" ]; then
  echo "Registry proxy is disabled"
  exit 0
fi

if [ "${DEBUG}" = "true" ]; then
  set -x
fi

# Setup a container registry mirror with cache capabilities
set -o errexit

KIND_NETWORK=${CLUSTER_NAME}
REGISTRY_NAME=${CLUSTER_NAME}-registry-proxy

# create docker volume
docker volume create "${CLUSTER_NAME}_docker_mirror_cache" || echo "Volume docker_mirror_cache already exist"
docker volume create "${CLUSTER_NAME}_docker_mirror_certs" || echo "Volume docker_mirror_certs already exist"

# start container registry unless it already exists
running="$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  echo "Running registry-proxy"
  docker run -d --name "${REGISTRY_NAME}" -it \
       --restart=always \
       --net "${KIND_NETWORK}" --hostname "${REGISTRY_NAME}" \
       -v "${CLUSTER_NAME}_docker_mirror_cache":/docker_mirror_cache \
       -v "${CLUSTER_NAME}_docker_mirror_certs":/ca \
       -e ENABLE_MANIFEST_CACHE=true \
       -e DISABLE_IPV6=true \
       -e REGISTRIES="docker.io registry.k8s.io k8s.gcr.io gcr.io quay.io" \
       -e AUTH_REGISTRIES="${DOCKER_REGISTRY}:${DOCKER_USERNAME}:${DOCKER_PASSWORD}" \
       jenciso/registry-proxy
fi

SETUP_URL=http://${REGISTRY_NAME}:3128/setup/systemd
pids=""
for NODE in $(kind get nodes --name "$CLUSTER_NAME"); do
  docker exec "$NODE" sh -c "\
      curl -s --retry 10 --retry-all-errors $SETUP_URL \
      | sed s/docker\.service/containerd\.service/g \
      | sed '/Environment/ s/$/ \"NO_PROXY=127.0.0.0\/8,10.0.0.0\/8,172.16.0.0\/12,192.168.0.0\/16\"/' \
      | bash" & pids="$pids $!" # Configure every node in background
done
wait $pids # Wait for all configurations to end
