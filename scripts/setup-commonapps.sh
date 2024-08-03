#!/bin/bash

if [[ ${DEBUG} = true ]]; then
  set -x
fi

## Install applications
cd kube-apps/common-apps || exit
helmfile apply
