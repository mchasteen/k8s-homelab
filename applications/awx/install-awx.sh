#!/bin/bash
#helm repo add awx-operator https://ansible.github.io/awx-operator/
#helm repo update
helm upgrade --install awx-operator awx-operator \
  --repo https://ansible.github.io/awx-operator/ \
  --namespace awx --create-namespace \
  -f ./values.yaml
sleep 30
#helm install my-awx-operator awx-operator/awx-operator -n awx --create-namespace -f ./values.yaml
kubectl get secret -n awx awx-admin-password -o jsonpath="{.data.password}" | base64 --decode ; echo

