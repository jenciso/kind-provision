# CREATE A KUBERNTES POC ENVIRONMENT

![](https://d33wubrfki0l68.cloudfront.net/d0c94836ab5b896f29728f3c4798054539303799/9f948/logo/logo.png)

## Overview

This repo contains install instructions to create a multi cluster kubernetes environment. The ideia is to have multiple cluster isolated using [Kind](https://kind.sigs.k8s.io/) and creating their docker networks for each cluster. We are using the experimental feature: `KIND_EXPERIMENTAL_DOCKER_NETWORK`.

## Prerequisites

* Docker
* Kind
* Helm
* Helmfile
* Kubectl
* Cloudflare DNS domain

## Getting Started

See the [INSTALL.md](INSTALL.md) file to provision a cluster with these components:

* MeltaLB 
* Ingress Nginx
* External-DNS
* Cert-Manager
* Kube-Replicator
* Metrics Server
* Kubernetes Dashboard
* Prometheus Stack

> You need to have a cloudflare domain and get your API token to manage your DNS domain via Cloudflare API.

To destroy read the [UNINSTALL.md](UNINSTALL.md) file.

-----

## Additional Notes

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

### Issues

https://github.com/kubernetes-sigs/kind/issues/2045


## References

Kubernetes Dashboard:
* https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

Kind Plugins
* https://github.com/aojea/kind-networking-plugins
