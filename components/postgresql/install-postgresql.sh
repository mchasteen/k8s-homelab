#!/bin/bash
kubectl create namespace postgresql

kubectl apply -d ./secret-postgresql.yaml

helm upgrade --install postgresql-db oci://registry-1.docker.io/bitnamicharts/postgresql \
  --namespace postgresql --create-namespace \
  -f ./values-postgresql.yaml \
  --version 16.4.8 \