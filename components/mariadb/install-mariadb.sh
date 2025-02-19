#!/bin/bash

NAMESPACE="mariadb"

kubectl create namespace $NAMESPACE

kubectl apply -n $NAMESPACE -f ./secret-mariadb.yaml

helm upgrade --install mariadb mariadb \
  --repo https://charts.bitnami.com/bitnami \
  --namespace $NAMESPACE --create-namespace \
  -f ./values-mariadb.yaml \
  --version 19.1.1