#!/bin/bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb-system \
  -n metallb-system --create-namespace \
  --version 0.13.9 \
  metallb/metallb
sleep 60
kubectl apply -f metallb_config.yaml
