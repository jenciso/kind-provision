# CREATE A KUBERNTES POC ENVIRONMENT

## Overview

This repo contains the install instructions for create a Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/)

## Prerequisites

* Docker
* Kind
* Helm
* Kubectl 

## Getting Started

See the [INSTALL.md] document and to deploy a demo application look at [examples](examples) directory.

## Notes

Knowing issues:

* To create a Kubernetes multinode is supported, but not recommended if you are using for long time. Consider using this multi-node only for dynamic creation. Kind has problem with the allocation ip address. See more information here: https://github.com/kubernetes-sigs/kind/issues/2045
