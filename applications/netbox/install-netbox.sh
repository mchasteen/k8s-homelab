#!/bin/bash
# https://artifacthub.io/packages/helm/bootc/netbox/2.2.0
# https://github.com/bootc/netbox-chart
# https://github.com/netbox-community/devicetype-library

helm upgrade --install netbox netbox \
    --repo https://charts.boo.tc \
    --namespace netbox --create-namespace \
    -f ./values-netbox.yaml \
    --set postgresql.auth.postgresPassword="password" \
    --set postgresql.auth.password="password" \
    --set redis.auth.password="password"
#    --wait
    
# helm repo add bootc https://charts.boo.tc
# helm repo update
# helm install netbox \
#   -n netbox --create-namespace \
#   --set postgresql.auth.postgresPassword="password" \
#   --set postgresql.auth.password="password" \
#   --set redis.auth.password="password" \
#   --set service.type=LoadBalancer \
#   bootc/netbox
