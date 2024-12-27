#!/bin/bash

# Add for reference
helm repo add longhorn https://charts.longhorn.io
helm repo update

helm upgrade --install longhorn longhorn \
  --repo  https://charts.longhorn.io \
  --namespace longhorn-system --create-namespace \
  -f ./values-longhorn.yaml \
  --version 1.7.2
