#!/bin/bash
# helm repo add pascaliske https://charts.pascaliske.dev
#helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes
#helm repo update
# helm install unbound -n unbound --create-namespace -f ./unbound-values.yaml pascaliske/unbound
helm upgrade --install unbound unbound \
  --repo https://charts.pascaliske.dev \
  --namespace unbound --create-namespace \
  --version 1.0.3 \
  -f ./values-unbound.yaml
sleep 30
# helm install pihole -n pihole --create-namespace -f ./pihole-kubernetes.yaml mojo2600/pihole
helm upgrade --install pihole pihole \
  --repo https://mojo2600.github.io/pihole-kubernetes \
  --namespace pihole --create-namespace \
  --version 2.14.0 \
  -f ./values-pihole.yaml
