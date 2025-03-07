#!/bin/bash

#helm repo add elastic https://helm.elastic.co
#helm repo update

helm upgrade --install elasticsearch elasticsearch \
  --repo https://helm.elastic.co \
  --namespace elastic-app --create-namespace \
  --version 8.5.1 #\
#  -f ./values-elasticsearch.yaml
