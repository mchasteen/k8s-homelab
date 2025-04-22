#!/bin/bash

kubectl create namespace envrionment-argocd-seed

# Can cause problems if bad character in the password
kubectl apply -n envrionment-argocd-seed -f ./resources/secret-argocd-seed.yaml

helm upgrade --install argocd-seed-keydb keydb \
  --repo  https://enapter.github.io/charts/ \
  --namespace envrionment-argocd-seed --create-namespace \
  --version 0.48.0 \
  -f ./values/values-keydb-seed.yaml \
  --wait

helm upgrade --install argocd-seed oci://ghcr.io/argoproj/argo-helm/argo-cd \
  --namespace envrionment-argocd-seed --create-namespace \
  -f ./values/values-argocd-seed.yaml \
  --version 7.8.27 \
  --wait

kubectl apply -f ./argocd/