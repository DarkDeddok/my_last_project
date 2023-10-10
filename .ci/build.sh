#!/usr/bin/env bash

set -x
set -e

sudo helm package ./openiam-pvc
sudo helm package ./openiam-configmap
sudo helm package ./openiam-gremlin
sudo helm package ./openiam-rproxy
sudo helm package ./openiam-vault
sudo helm package ./openiam
