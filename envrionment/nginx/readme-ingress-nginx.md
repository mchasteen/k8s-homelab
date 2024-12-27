# Links

# Commands for testing certs:

kubectl get secret -n myapp myapp.home.local-tls  -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout


# Grafana

21336

https://grafana.com/grafana/dashboards/21336-nginx-ingress-controller/