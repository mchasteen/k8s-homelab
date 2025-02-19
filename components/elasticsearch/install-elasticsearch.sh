#!/bin/bash

#helm repo add elastic https://helm.elastic.co
#helm repo update

helm upgrade --install elasticsearch elasticsearch \
  --repo https://helm.elastic.co \
  --namespace elastic-app --create-namespace \
  --version 0.48.0 #\
#  -f ./values-elasticsearch.yaml
