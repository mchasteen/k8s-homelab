#!/bin/bash
#helm repo add elastic https://helm.elastic.co
#helm repo update

# Needs to be installed after elastic is compeltely up.
helm upgrade --install elasticsearch-kibana kibana \
  --repo https://helm.elastic.co \
  --namespace elastic-app --create-namespace \
  --version 8.5.1 \
  -f ./values-kibana.yaml



