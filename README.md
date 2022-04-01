# CREATE A KUBERNTES POC ENVIRONMENT

## Overview

This repo contains the install instructions for create a Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/) with all theses components:

* MeltaLB
* Ingress Nginx
* External-DNS
* Cert-Manager
* Kube-Replicator
* Metrics Server
* Kuberntes Dashboard

## Prerequisites

* Docker
* Kind
* Helm
* Kubectl
* Cloudflare DNS domain

## Getting Started

See the [INSTALL.md](INSTALL.md) file to provision a Kubernetes cluster. You need to have a cloudflare domain and get your API token to manage your DNS domain via Cloudflare API.

In the [examples](examples) directory you can find documments to provision different scenarios.

Finally, to destroy read the [UNINSTALL.md](UNINSTALL.md) documment.

## Notes

### Knowing issues:

* Multinode kubernetes is supported, but it is not recommended if you are using for long time. Consider use multi-node for dynamic/test environment only. It's known that Kind doesn't preserves the allocation ip address. See more information here: https://github.com/kubernetes-sigs/kind/issues/2045
