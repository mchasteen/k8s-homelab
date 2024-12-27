#!/bin/bash

kubectl create namespace external-dns
kubectl apply -f secret-pihole.yaml

helm upgrade --install external-dns external-dns \
  --repo https://kubernetes-sigs.github.io/external-dns/ \
  --namespace external-dns --create-namespace \
  -f ./values-external-dns.yaml \
  --version 1.15.0