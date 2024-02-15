# Kubernetes local provision with Kind

## Overview

This repo contains all the needed to create a kubernetes cluster with kind. 

It has support to run a multi cluster environment, we are using the experimental feature: `KIND_EXPERIMENTAL_DOCKER_NETWORK` to isolate the clusters.

## Prerequisites

* Docker
* Kind
* Helm
* Helmfile
* Kubectl
* Cloudflare Account with a custom domain configured
> You need to have a cloudflare domain and get your API token to manage your DNS domain via Cloudflare API.


## Getting Started

Create a `.env` file similar to `.env.sample`

Directories and files:

```shell
➜ tree -d -L 2
.
├── kube-apps
│   ├── base-apps
│   └── core-apps
└── scripts
```

In the `core-apps` directory is a helmfile declaring the core applications to be installed. The same happens with `base-apps`
The `scripts.sh` has the scripts used in the `Makefile`


To provision
```
make provision
``` 

To destroy
```
make destroy
```

-----

## Using the cluster

### Running a nginx-demo application

Creating a namespace "demos"
```
kubectl create ns demos
kubectl create deployment -n demos --image=nginx nginx-demo
kubectl create service -n demos clusterip nginx-demo --tcp=80:80
```

Creating an ingress resource and request a certificate
```
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
```
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

```
kubectl apply -f /tmp/ingress.yaml
```
