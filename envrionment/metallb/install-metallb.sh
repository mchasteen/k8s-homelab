#!/bin/bash

# Add repo just to have
helm repo add metallb https://metallb.github.io/metallb
helm repo update


helm upgrade --install metallb-system metallb \
  --repo https://metallb.github.io/metallb \
  --namespace metallb-system --create-namespace \
  -f ./values-metallb.yaml \
  --version 0.14.9

# Apply this later
sleep 60
kubectl apply -f metallb_config.yaml
