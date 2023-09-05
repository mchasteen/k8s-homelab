#!/bin/bash
#helm repo add longhorn https://charts.longhorn.io
#helm repo update
#helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.1
#helm install longhorn longhorn/longhorn \
#  --namespace longhorn-system \
#  --create-namespace \
#  --values values.yaml


helm upgrade --install longhorn longhorn \
  --repo  https://charts.longhorn.io \
  --namespace longhorn-system --create-namespace \
  --version 1.5.1
