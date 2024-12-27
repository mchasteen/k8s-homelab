#!/bin/bash
# Add repo just to have
helm repo add secrets-generator https://helm.mittwald.de
helm repo update

helm upgrade --install secret-generator kubernetes-secret-generator \
  --repo https://helm.mittwald.de \
  --namespace secret-generator --create-namespace \
  -f ./values-secrets-generator.yaml