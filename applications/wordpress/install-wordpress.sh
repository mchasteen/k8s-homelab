#!/bin/bash

# elm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo update
# helm install wordpress1 bitnami/wordpress

helm upgrade --install wordpress-1 wordpress \
  --repo https://charts.bitnami.com/bitnami \
  --namespace wordpress-1 --create-namespace \
  -f ./values-wordpress.yaml
