#!/bin/bash

kubectl -n longhorn-system apply -f ./oauth2-proxy-longhorn-dashboard.yaml

kubectl -n longhorn-system apply -f ./oauth2-ingress-longhorn-dashboard.yaml
