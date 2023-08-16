#!/bin/bash

helm upgrade --install step-issuer step-issuer \
  --repo https://smallstep.github.io/helm-charts/ \
  --namespace step-ca --create-namespace \
  --wait

CA_URL=https://step-certificates.step-ca.svc.cluster.local
CERT_CHAIN=/opt/ca/intermediate/certs/ca-chain.cert.pem
CA_BUNDLE=`cat $CERT_CHAIN | base64 | tr -d '\n'`

CA_PROVISIONER_NAME=$(kubectl get -o jsonpath="{.data['ca\.json']}" -n step-ca configmaps/step-certificates-config | jq -r .authority.provisioners[0].name)
CA_PROVISIONER_KID=$(kubectl get -o jsonpath="{.data['ca\.json']}" -n step-ca configmaps/step-certificates-config | jq -r .authority.provisioners[0].key.kid)

cat <<EOF > step-issuer.yaml
---
apiVersion: certmanager.step.sm/v1beta1
kind: StepIssuer
metadata:
  name: step-issuer
  namespace: step-ca
spec:
  # The CA URL:
  url: $CA_URL
  # The base64 encoded version of the CA root certificate in PEM format:
  caBundle: $CA_BUNDLE
  # The provisioner name, kid, and a reference to the provisioner password secret:
  provisioner:
    name: $CA_PROVISIONER_NAME
    kid: $CA_PROVISIONER_KID
    passwordRef:
      name: step-certificates-provisioner-password
      key: password
---
EOF

kubectl apply -f step-issuer.yaml

cat <<EOF > step-cluster-issuer.yaml
---
apiVersion: certmanager.step.sm/v1beta1
kind: StepClusterIssuer
metadata:
  name: step-cluster-issuer
spec:
  # The CA URL:
  url: $CA_URL
  # The base64 encoded version of the CA root certificate in PEM format:
  caBundle: $CA_BUNDLE
  # The provisioner name, kid, and a reference to the provisioner password secret:
  provisioner:
    name: $CA_PROVISIONER_NAME
    kid: $CA_PROVISIONER_KID
    passwordRef:
      name: step-certificates-provisioner-password
      key: password
      namespace: step-ca
---
EOF

kubectl apply -f step-cluster-issuer.yaml


# Working example usage:
#
# ingress:
#   enabled: true
#   annotations:
#     external-dns.alpha.kubernetes.io/hostname: "netbox.home.local"
#     kubernetes.io/ingress.class: "nginx"
#     #kubernetes.io/tls-acme: "true"
#     cert-manager.io/issuer-group: certmanager.step.sm
#     cert-manager.io/issuer-kind: StepClusterIssuer
#     cert-manager.io/issuer: step-cluster-issuer
#   hosts:
#     - host: netbox.home.local
#       paths:
#         # NB: You may also want to set the basePath above
#         - /
# 
#   tls:
#     - secretName: netbox-tls
#       hosts:
#         - netbox.home.local

