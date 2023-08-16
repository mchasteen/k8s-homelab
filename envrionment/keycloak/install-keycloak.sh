#!/bin/bash


helm upgrade --install keycloak keycloak \
  --repo https://charts.bitnami.com/bitnami \
  --namespace keycloak --create-namespace \
  -f ./values-keycloak.yaml


#WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/mchasteen/.kube/config
#WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/mchasteen/.kube/config
#Release "keycloak" does not exist. Installing it now.
#NAME: keycloak
#LAST DEPLOYED: Mon Jun  5 23:43:24 2023
#NAMESPACE: keycloak
#STATUS: deployed
#REVISION: 1
#TEST SUITE: None
#NOTES:
#CHART NAME: keycloak
#CHART VERSION: 15.1.2
#APP VERSION: 21.1.1
#
#** Please be patient while the chart is being deployed **
#
#Keycloak can be accessed through the following DNS name from within your cluster:
#
#    keycloak.keycloak.svc.cluster.local (port 80)
#
#To access Keycloak from outside the cluster execute the following commands:
#
#1. Get the Keycloak URL and associate its hostname to your cluster external IP:
#
#   export CLUSTER_IP=$(minikube ip) # On Minikube. Use: `kubectl cluster-info` on others K8s clusters
#   echo "Keycloak URL: https://keycloak.home.local/"
#   echo "$CLUSTER_IP  keycloak.home.local" | sudo tee -a /etc/hosts
#
#2. Access Keycloak using the obtained URL.
#3. Access the Administration Console using the following credentials:
#
#  echo Username: admin
#  echo Password: $(kubectl get secret --namespace keycloak keycloak -o jsonpath="{.data.admin-password}" | base64 -d)
