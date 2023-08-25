#!/bin/bash

# Needs to be named custom-ca-bundle.pem
cp /opt/ca/intermediate/certs/ca-chain.cert.pem  ./custom-ca-bundle.pem
kubectl create namespace kasten-io
kubectl -n kasten-io create configmap custom-ca-bundle-store --from-file=./custom-ca-bundle.pem

helm upgrade --install k10 k10 \
  --repo  https://charts.kasten.io/ \
  --namespace kasten-io --create-namespace \
  --version 5.5.11 \
  -f ./values-kasten.yaml \
  --wait

kubectl annotate volumesnapshotclass \
  "$(kubectl get volumesnapshotclass -o=jsonpath='{.items[?(@.metadata.annotations.snapshot\.storage\.kubernetes\.io\/is-default-class=="true")].metadata.name}')" \
  k10.kasten.io/is-snapshot-class=true

#WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/mchasteen/.kube/config
#WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/mchasteen/.kube/config
#Release "k10" has been upgraded. Happy Helming!
#NAME: k10
#LAST DEPLOYED: Thu Jun 15 18:13:21 2023
#NAMESPACE: kasten-io
#STATUS: deployed
#REVISION: 7
#TEST SUITE: None
#NOTES:
#Thank you for installing Kasten’s K10 Data Management Platform 5.5.11!
#
#Documentation can be found at https://docs.kasten.io/.
#
#How to access the K10 Dashboard:
#
#You are using the system's default ingress controller. Please ask your
#administrator for instructions on how to access the cluster.
#
#WebUI location:  https://kasten.home.local/k10
#
#In addition,
#
#To establish a connection to it use the following `kubectl` command:
#
#`kubectl --namespace kasten-io port-forward service/gateway 8080:8000`
#
#The Kasten dashboard will be available at: `http://127.0.0.1:8080/k10/#/`
