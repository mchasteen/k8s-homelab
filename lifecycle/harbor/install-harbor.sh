#!/bin/bash

helm upgrade --install harbor harbor \
  --repo  https://helm.goharbor.io \
  --namespace harbor --create-namespace \
  --version 1.13.0 \
  --set harborAdminPassword="$(cat password-harbor-admin.txt | base64 -d)" \
  -f ./values-harbor.yaml \
  --wait
  
# admin Password is "password"
# Update password-harbor-admin.txt with a new base64 encoded password.
