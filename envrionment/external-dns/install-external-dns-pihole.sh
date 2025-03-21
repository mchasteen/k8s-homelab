#!/bin/bash

kubectl create namespace envrionment-external-dns
kubectl apply -n envrionment-external-dns -f ./resources/secret-pihole.yaml

helm upgrade --install external-dns-pihole external-dns \
  --repo https://kubernetes-sigs.github.io/external-dns/ \
  --namespace envrionment-external-dns --create-namespace \
  -f ./values/values-external-dns-pihole.yaml \
  --version 1.15.2
