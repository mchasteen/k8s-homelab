#!/bin/bash
# https://adamtheautomator.com/prometheus-kubernetes/

# Make sure 9100 is open on all nodes!
# firewall-cmd --add-port=9100/tcp --permanent

kubectl apply -f secret-grafana.yaml

helm upgrade --install kube-prometheus-stack kube-prometheus-stack \
  --repo  https://prometheus-community.github.io/helm-charts \
  --namespace monitoring --create-namespace \
  -f ./values-monitoring-stack.yaml \
  --version 67.2.0 \
  --wait
