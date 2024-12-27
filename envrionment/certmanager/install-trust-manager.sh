#!/bin/bash

# Add for reference
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install trust-manager trust-manager \
  --repo https://charts.jetstack.io \
  --namespace cert-manager --create-namespace \
  --version v0.14.0 \
  -f ./values-trust-manager.yaml \
  --wait

kubectl apply -f ./bundle-ca-certs.yaml