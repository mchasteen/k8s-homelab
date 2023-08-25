#!/bin/bash

echo "Enter a password for user 'admin':"
htpasswd -c auth admin

kubectl -n longhorn-system create secret generic longhorn-basic-auth --from-file=auth


cat <<EOF > ingress-longhorn-dashboard.yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: longhorn-ingress
  namespace: longhorn-system
  annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    #nginx.ingress.kubernetes.io/ssl-redirect: 'false'
    nginx.ingress.kubernetes.io/auth-secret: longhorn-basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required '
    cert-manager.io/issuer: step-cluster-issuer
    cert-manager.io/issuer-group: certmanager.step.sm
    cert-manager.io/issuer-kind: StepClusterIssuer
    external-dns.alpha.kubernetes.io/hostname: longhorn.home.local

spec:
  ingressClassName: nginx
  rules:
  - host: longhorn.home.local
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: longhorn-frontend
            port:
              number: 80
  tls:
  - hosts:
    -  longhorn.home.local
    secretName:  longhorn.home.local-tls

EOF

kubectl -n longhorn-system apply -f ./ingress-longhorn-dashboard.yaml
