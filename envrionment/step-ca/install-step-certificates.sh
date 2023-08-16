#!/bin/bash
ROOT_CERT='/opt/ca/certs/ca.cert.pem'
INT_CERT='/opt/ca/intermediate/certs/intermediate.cert.pem'
INT_CERT_KEY='/opt/ca/intermediate/private/intermediate.key.pem'
ROOT_CERT_FORMATTED=`cat $ROOT_CERT | sed 's/^/      /'`
ROOT_CERT_FINGERPRINT=`openssl x509 -noout -fingerprint -sha256 -in $ROOT_CERT | cut -f2 -d'=' | sed s/://g`
INT_CERT_FORMATTED=`cat $INT_CERT | sed 's/^/      /'`
INT_CERT_KEY_FORMATTED=`cat $INT_CERT_KEY | sed 's/^/        /'`
PROVISIONER_JWK=`cat './provisioner-jwk.txt'`

echo $ROOT_CERT_FINGERPRINT

cat <<EOF > values-step-certificates.yaml
# Helm template
inject:
  enabled: true
  # Config contains the configuration files ca.json and defaults.json
  config:
    files:
      ca.json:
        root: /home/step/certs/root_ca.crt
        federateRoots: []
        crt: /home/step/certs/intermediate_ca.crt
        key: /home/step/secrets/intermediate_ca_key
        address: :9000
        dnsNames:
          - step-certificates.step-ca.svc.cluster.local # This is service-name.namespace.svc.cluster.local
          - step-certificates.home.local  # Add extra DNS names for your network here
        logger:
          format: json
        db:
          type: badgerv2
          dataSource: /home/step/db
        authority:
          enableAdmin: false
          provisioners:
            - $PROVISIONER_JWK
        tls:
          cipherSuites:
            - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
            - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
          minVersion: 1.2
          maxVersion: 1.3
          renegotiation: false

      defaults.json:
        ca-url: https://step-certificates.step-ca.svc.cluster.local
        ca-config: /home/step/config/ca.json
        fingerprint: $ROOT_CERT_FINGERPRINT
        root: /home/step/certs/root_ca.crt

  # Certificates contains the root and intermediate certificate and 
  # optionally the SSH host and user public keys
  certificates:
    # intermediate_ca contains the text of the intermediate CA Certificate
    intermediate_ca: |
$INT_CERT_FORMATTED
      
      
    # root_ca contains the text of the root CA Certificate
    root_ca: |
$ROOT_CERT_FORMATTED

  # Secrets contains the root and intermediate keys and optionally the SSH
  # private keys
  secrets:
    # ca_password contains the password used to encrypt x509.intermediate_ca_key, ssh.host_ca_key and ssh.user_ca_key
    # This value must be base64 encoded.
    ca_password: 
    provisioner_password: 

    x509:
      # intermediate_ca_key contains the contents of your encrypted intermediate CA key
      intermediate_ca_key: |
$INT_CERT_KEY_FORMATTED
        

      # root_ca_key contains the contents of your encrypted root CA key
      # Note that this value can be omitted without impacting the functionality of step-certificates
      # If supplied, this should be encrypted using a unique password that is not used for encrypting
      # the intermediate_ca_key, ssh.host_ca_key or ssh.user_ca_key.
      root_ca_key: ""

# service contains configuration for the kubernes service.
service:
  type: LoadBalancer  # We are using a LoadBalancer service setting since step-certificates issues it's own cert.
  port: 443
  targetPort: 9000
  nodePort: ""
  annotations:
    external-dns.alpha.kubernetes.io/hostname: "step-certificates.home.local"  # This is for external-dns to create a DNS name outside the cluster.  Make sure to add it above in the "dnsNames" section.
          
EOF

helm upgrade --install step-certificates step-certificates \
  --repo https://smallstep.github.io/helm-charts/ \
  --namespace step-ca --create-namespace \
  -f ./values-step-certificates.yaml \
  --set inject.secrets.ca_password=$(cat password-int-ca.txt) \
  --set inject.secrets.provisioner_password=$(cat password-provider.txt) \
  --wait
#  --set service.targetPort=9000 \
#  --set service.type=LoadBalancer

# Testing:
# step ca health --ca-url https://step-certificates.step-ca.svc.cluster.local --root /opt/ca/certs/ca.cert.pem
  
#  1. Get the PKI and Provisioner secrets running these commands:
#   kubectl get -n step-ca-test -o jsonpath='{.data.password}' secret/step-ca-test-step-certificates-ca-password | base64 --decode
#   kubectl get -n step-ca-test -o jsonpath='{.data.password}' secret/step-ca-test-step-certificates-provisioner-password | base64 --decode



