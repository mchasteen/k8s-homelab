#!/bin/bash

NAMESPACE="keydb"

kubectl create namespace $NAMESPACE

kubectl apply -n $NAMESPACE -f ./secret-keydb.yaml

helm upgrade --install keydb keydb \
  --repo  https://enapter.github.io/charts/ \
  --namespace $NAMESPACE --create-namespace \
  --version 0.48.0 \
  -f ./values-keydb.yaml \
  --wait