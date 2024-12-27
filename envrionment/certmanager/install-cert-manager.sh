#!/bin/bash

# Add for reference
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager cert-manager \
  --repo https://charts.jetstack.io \
  --namespace cert-manager --create-namespace \
  --version v1.16.2 \
  -f ./values-cert-manager.yaml \
  --wait
kubectl apply -f ./clusterissuer-cert-manager-selfsigned.yaml
