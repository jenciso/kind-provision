#!/bin/bash

if [[ ${DEBUG} = true ]]; then
  set -x
fi

## Install applications
cd kube-apps/base-apps
helmfile apply
