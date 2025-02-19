#!/bin/bash

#helm repo add elastic https://helm.elastic.co
#helm repo update

NAMESPACE="elastic-app"

helm upgrade --install elasticsearch elasticsearch \
  --repo https://helm.elastic.co \
  --namespace $NAMESPACE --create-namespace #\
#  -f ./values-elasticsearch.yaml

seconds=1; echo -n "Waiting for it Elasticsearch resources to be deployed"; until kubectl get statefulsets.apps -n $NAMESPACE elasticsearch-master -o jsonpath='{.status.availableReplicas}' > /dev/null 2>&1; do >&2 echo -n "."; sleep 1; seconds=$(expr $seconds + 1); done; echo ""

seconds=1; echo -n "Waiting for it Elasticsearch"; until [ $(kubectl get statefulsets.apps -n $NAMESPACE elasticsearch-master -o jsonpath='{.status.availableReplicas}') -gt 0 ]; do >&2 echo -n "."; sleep 1; seconds=$(expr $seconds + 1); done; echo ""

# Needs to be installed after elastic is compeltely up.
helm upgrade --install elasticsearch-kibana kibana \
  --repo https://helm.elastic.co \
  --namespace $NAMESPACE --create-namespace \
  -f ./values-kibana.yaml


