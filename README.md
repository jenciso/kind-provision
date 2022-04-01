# CREATE A KUBERNTES POC ENVIRONMENT

![](https://d33wubrfki0l68.cloudfront.net/d0c94836ab5b896f29728f3c4798054539303799/9f948/logo/logo.png)

## Overview

This repo contains install instructions to create a multi cluster kubernetes environment. The ideia is to have multiple cluster isolated using [Kind](https://kind.sigs.k8s.io/) and creating their docker networks for each cluster. We are using the experimental feature: `KIND_EXPERIMENTAL_DOCKER_NETWORK`.

## Prerequisites

* Docker
* Kind
* Helm
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
* Kuberntes Dashboard

> You need to have a cloudflare domain and get your API token to manage your DNS domain via Cloudflare API.

In the [examples](examples) directory you can find documments to provision different scenarios.

To destroy read the [UNINSTALL.md](UNINSTALL.md) file.

## Knowing issues:

* Multinode kubernetes is supported, but it is not recommended if you are using for long time. Consider use multi-node for dynamic/test environment only. It's known that Kind doesn't preserves the allocation ip address. See more information here: https://github.com/kubernetes-sigs/kind/issues/2045
