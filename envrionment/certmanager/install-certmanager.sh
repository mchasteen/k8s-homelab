#!/bin/bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager --namespace cert-manager --create-namespace --version v1.11.2 --set installCRDs=true jetstack/cert-manager
kubectl apply -f ./cert-manager-selfsigned.yaml
