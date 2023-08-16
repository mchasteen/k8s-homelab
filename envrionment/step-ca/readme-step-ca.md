# Creating Your Own Two-Teir PKI

Start following the instructions below:

https://openssl-ca.readthedocs.io/en/latest/introduction.html

*Note: Instead of using /root I use /opt since that is a normal folder in the linux file structure.  You may want to use /root if you end up using a chroot jail.*

Save your intermediate password, base 64 encoded, in a text file.

`echo "intermediate-ca-password" | base64 > password-int-ca.txt`

# Install Step-Cli

Install step-cli.

https://smallstep.com/docs/step-cli/installation/

For EL based Linux distros:

`wget https://dl.smallstep.com/gh-release/cli/docs-ca-install/v0.23.2/step-cli_0.23.2_amd64.rpm`

`sudo dnf install step-cli_0.23.2_amd64.rpm`

# Generate Information for Installing Step-Certificates

For reference for the folling steps:

https://artifacthub.io/packages/helm/smallstep/step-certificates

Run:

`step ca init --helm > values-step-cerificates.yaml`

When prompted:

*Standalone*

URL:

step-certificates.step-ca.svc.cluster.local

*Note: Format is kubernetes service-name.namespace.svc.cluster.local*

Port:

9000

*Note: This port will be the cluster port. Step-Certificates *

Email:

*your@email.com*

Let it generate a random password and save it to text file called password-provider:

`echo "password-you-just-got" | base64 > password-provider.txt`

Open your values.yaml file you just created.

Cut the provisioner line beginning with `{"type":"JWK",` and put it in a file called `provisioner-jwk.txt`

Open and review the `install-step-certificates.sh` and make sure all the dns settings are correct and the file paths are correct to your root and intermediate certificates.

# Run Step-Certificates Installer

Run:

`./install-step-certificates.sh`

*Note: Most of the values-step-certificates.yaml are part of the install script.  Only the password and the JWT are really generated with the init command.  The script will generate the values file and that can be edited and reapplied if needed.*

# Check Health of Step-Certificates

One the application is up, check the stats of the step-ca server with:

https://step-certificates.home.local/health

which should return:

`{"status":"ok"}`

Step-cli can be also used to verify the health:

`step ca health --ca-url https://step-certificates.home.local --root /opt/ca/certs/ca.cert.pem`

*Note: Make sure to replace the path to the root cert with the path to your root cert.*

# Install Step-Issuer

Installing Step-Issuer will allow cert-manager to automatically issue and aprove certifcates for your applications.

Open and review the `install-step-issuer.sh` and make sure all the settings are correct.

*Note: Step-Issuer will only issue certificates to services or ingress in the same namespace.  Step-Cluster-Issuer will all distribution and auto-aproval of certificates to all namespaces in a cluster.*

Once the step-certificates is installed, install step-issuer:

Run:

`./install-step-issuer.sh`

# Example Usage

Here is an example from a Netbox values.yaml file:

```
ingress:
  enabled: true
  annotations:
    external-dns.alpha.kubernetes.io/hostname: "netbox.home.local"
    kubernetes.io/ingress.class: "nginx"
    #kubernetes.io/tls-acme: "true"
    cert-manager.io/issuer-group: certmanager.step.sm
    cert-manager.io/issuer-kind: StepClusterIssuer
    cert-manager.io/issuer: step-cluster-issuer
  hosts:
    - host: netbox.home.local
      paths:
        # NB: You may also want to set the basePath above
        - /
  tls:
    - secretName: netbox-tls
      hosts:
        - netbox.home.local
```

Notice the use of the cert-manager annotations.
