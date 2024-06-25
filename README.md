# Kubernetes local provision with Kind

![](https://i.octopus.com/blog/2020-01/kubernetes-with-kind/kubernetes-in-docker.png)

## Overview

This repo contains all the needed to create a kubernetes cluster with kind.

It supports multi cluster environment provision. It use the experimental kind feature: `KIND_EXPERIMENTAL_DOCKER_NETWORK`
to create different network by cluster.

## Prerequisites

- Docker
- Kind
- Helm
- Helmfile
- Kubectl
- Cloudflare Account with a custom domain configured
  > You need to have a cloudflare domain and get your API token to manage your DNS domain via Cloudflare API.

## Getting Started

Create a `.env` file similar to `.env.sample`

Directories and files:

```shell
➜ tree -d -L 2
.
├── kube-apps
│   ├── common-apps
│   └── core-apps
└── scripts
```

In the `core-apps` directory is a helmfile declaring the core applications to be installed. The same happens with `base-apps`
The `scripts.sh` has the scripts used in the `Makefile`

To provision

```shell
make provision
```

> It is divided in two stages: `make install` and `make setup`

To destroy

```shell
make destroy
```

---

## Using the cluster

### Running a nginx-demo application

Creating a namespace "demos"

```shell
kubectl create ns demos
kubectl create deployment -n demos --image=nginx nginx-demo
kubectl create service -n demos clusterip nginx-demo --tcp=80:80
```

Creating an ingress resource and request a certificate

```shell
cat << EOF > /tmp/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: letsencrypt-prd-cloudflare
  name: nginx-demo
  namespace: demos
spec:
  rules:
  - host: nginx-demo.${CLUSTER_NAME}.${SITE_DOMAIN}
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: nginx-demo
            port:
              number: 80
  tls:
  - hosts:
    - nginx-demo.${CLUSTER_NAME}.${SITE_DOMAIN}
    secretName: nginx-demo-cert
EOF
```

Using a wildcard certificate

```shell
cat << EOF > /tmp/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: "nginx"
  name: nginx-demo
  namespace: demos
spec:
  rules:
  - host: nginx-demo.${CLUSTER_NAME}.${SITE_DOMAIN}
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: nginx-demo
            port:
              number: 80
  tls:
  - hosts:
    - nginx-demo.${CLUSTER_NAME}.${SITE_DOMAIN}
    secretName: cert-wildcard
EOF
```

Applying manifest

```shell
kubectl apply -f /tmp/ingress.yaml
```
