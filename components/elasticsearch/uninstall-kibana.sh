#!/bin/bash

NAMESPACE="elastic-app"

helm uninstall -n $NAMESPACE elasticsearch-kibana

kubectl delete configmap -n $NAMESPACE elasticsearch-kibana-kibana-helm-scripts

kubectl delete role -n $NAMESPACE pre-install-elasticsearch-kibana-kibana

kubectl delete rolebinding -n $NAMESPACE pre-install-elasticsearch-kibana-kibana

kubectl delete configmap -n $NAMESPACE elasticsearch-kibana-kibana-helm-scripts

kubectl delete job -n $NAMESPACE pre-install-elasticsearch-kibana-kibana

kubectl delete serviceaccount -n $NAMESPACE pre-install-elasticsearch-kibana-kibana