#!/bin/bash

kubectl create namespace envrionment-external-dns
kubectl apply -n envrionment-external-dns -f ./resources/secret-rfc2136.yaml

helm upgrade --install external-dns-rfc2136 external-dns \
  --repo https://kubernetes-sigs.github.io/external-dns/ \
  --namespace envrionment-external-dns --create-namespace \
  -f ./values/values-external-dns-rfc2136.yaml \
  --version 1.15.2
