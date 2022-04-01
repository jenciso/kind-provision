# CREATE A KUBERNTES POC ENVIRONMENT

![](https://d33wubrfki0l68.cloudfront.net/d0c94836ab5b896f29728f3c4798054539303799/9f948/logo/logo.png)

## Overview

This repo contains the install instructions to create multiples Kubernetes cluster isolated using [Kind](https://kind.sigs.k8s.io/) and its experimental feature: `KIND_EXPERIMENTAL_DOCKER_NETWORK`.

Also, you could also install the following components:

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
