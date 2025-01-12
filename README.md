# Disclaimer
***While I am a professional technological monkey, this is my own test lab settings.  This is not to be used in production and is presented as-is.***

***I am learning still, as I hope we all are, so this will change as I learn.  What is below is currently working for me now.***

# Plan

I am using [K3S](https://docs.k3s.io/) for my home lab.  It is simple to install (for a moderate linux user) on extra hardware/junk you may have lying around.

### Terminology
Node == Host (in VMware or virtualization terms) or Server.

## Deployment Architecture
Decide what the [architecture](https://docs.k3s.io/architecture) of your K3S cluster will be.

Possible setups include:
- Single K3S node.
- K3s cluster with one control plane node and worker nodes (in k3s, pods will be scheduled on the control-plane node by default)
- Cluster with 3 or more nodes, and etcd.

Decide also what IP space you will use.  Set aside a chunk of your home lab network for applications you will deploy.

Example:

- 192.168.0.15-19 for static IPs.
- 192.168.0.25-150 for dynamic IPs.

I use two IP pools.  One IP pool for dynamically allocated IPs for applications and one for statically assigned IPs.  You really won't need many static IPs in the static pool.  I only use them for my home lab DNS services when I need an IP.  Once you install the external-dns plugin, kubernetes will dynamically add DNS records for the services you deploy.

## Node Hardware
You do not need the same [hardware](https://docs.k3s.io/installation/requirements#hardware) for each node, but I do recommend the same [processor architecture](https://docs.k3s.io/installation/requirements#architecture) (x86_64 vs arm64).

Recommended hardware:

- Whatever is lying around. :thumbsup:
- Dell/Lenovo/HP/other micro form factor.
- BeeLink or similar small computer.
- Mac Mini. Make sure to set an extra setting in the GRUB when booting to the Linux installer. [Tutorial.](https://linuxhint.com/install_linux_on_mac/)
- If you are crazy and have rack-mounted servers in your "lab" use those.

## Node OS
Decide the node (server) [OS](https://docs.k3s.io/installation/requirements#operating-systems) you will use to host K3s.

I chose OpenSuSE leap as my base OS, which is in the enterprise linux vein, since is K3s is related to or product of Rancher (also produces Longhorn distributed storage), and Rancher which is "by" SuSE...Which OpenSuse Leap is the opensource upstream distro of SUSE Entierprise Linux (SLES).

Also, I have been around SuSE since before Novell bought them (back when it came on a CD) and I am comfortable with the system. It is very stable overall and supports many different Linux skill levels. The system can be configured using their configuration tool called YaST which has a GUI and CLI client.

Good Linux OSes, order ranked for Linux n00bs:

- OpenSuSE
- CentOS Stream or Fedora Server (or Rocky Linux?)
- Debian
- Xubuntu or Lubuntu
- Ubuntu Server (I dont like it as much for multiple reasons but one reason is because they have some unique tools and have not followed some enterprise linux distros tools but, on a positive, there is a lot of documentation/how-tos)

Personally nowadays I would recommend someone new to Linux (servers) something like YaST. For someone comfortable with the command line I would recommend anything with Network Manager, systemd, and firewalld.

<!-- <sub>*yes...yes, Heresy! Heresy! to old-school Linux/Unix users. As someone who has used and managed as my job Redhat (and EL derivatives), SLES (and OpenSuSE), Debian (and derivatives), Ubuntu Server, FreeBSD, SANs (such as NetApp's 7-mode..FreeBSD), switches, routers, etc., etc. systems of vastly different ages, having a single consistent way of managing networking, firewall, and services is important to me. I don't care about your script-fu awk, sed, shell, perl, python, whatever mangled unreadable shell script or whatever you are proficient with, I just want the job done, in a consistent way, with flexibility of input and output.</sub>  -->

So if you are newish to Linux and want to just try a physical Kubernetes deployment on hardware outside of minikube, install OpenSuSE with a graphical interface. Use YaST to configure everything. If you download and install the full "offline" installer, you typically have a GUI-based installer where you can configure the network, time, storage, and users. Document the menu steps and as you progress you can eventually use YaST in a non-graphical environment (CLI) and eventually Network Manager CLI (nmcli), firewalld (firewall-cmd), and systemd (systemctl).

*See:*
https://docs.k3s.io/architecture

## Configure DNS
***Configure DNS records for all k3s nodes you will have.***

Go ***NOW***--this point of the process--and put in forward (A) and reverse (PTR) DNS records for your nodes. Plan the ***FQDNs*** (such as node01.my.localdomain) and add them. I also add the FQDNs to the local `/etc/hosts` file (just in case) but remember that they are there in case you change an FQDN or IP address.

If you do not have a good DNS server and search domain/zone, go create one now. That garbage ISR with WIFI that the ISP gave you is trash (most likely). I recommend using [pihole](https://pi-hole.net) to manage your lab's (and home's) DNS as it will integrate with the external-dns plugin in Kubernetes so DNS can be dynamically updated and it will also do DHCP for your lab (outside of the Kubernetes cluster). Pihole does not need to be on a Raspberry Pi, I have it on x86_64 hardware and you can also run it in your K3S cluster at some point. Many issues you encounter in setting up K3S will be solved by using correct DNS.

*See:*
https://docs.k3s.io/installation/requirements

Example planning:
|DNS Name|IP Address| Role|
|--|--|--|
|k3s-n0.home.local|192.168.0.10|all in one|

|K3S IP Pool Name|IP Range|
|--|--|
|home-pool (dynamic)|192.168.0.25-150|
|home-pool-static|192.168.0.15-19|

*Note: These pools are for service "Loadbalancer" values that metallb will broadcast ARP to the network.* 

|Decision|Value|Reason|
|--|--|--|
|How many nodes do I need?|1|Only one spare piece of junk|
|How many disks do I have?|1|I found only one that works|
|What is my disk size?|500GB|All I got|
|Do I have enough space on the disk for pod storage?|Yes|For my needs, yes|
|Do I need etcd?|No|Only one node|
|Do I need shared storage?|No|Only one node|
|Do I want my DNS auto updated?|Yes|Deploy external-dns|
|Do I have a DNS server that is compatible with external-dns?|No|Deploy Pi-Hole|
|Do I want to create my own PKI?|Yes|Follow [step-certificates and step-issuer](environment/step-ca/readme-step-ca.md)|
|Do I want to create my own auth system?|Yes|Install Keycloak|
|etc...|etc...|etc...|



# Install and Configure Node
## Install OS
Follow these general instructions (I wrote the notes for myself):

- Download OpenSuse Leap and burn to USB.
- Boot to installer.
- When the graphical installer comes up, yes online repos.
- Use default repos.
- System Role: Server
- For disk install selection (next for each step)
  - Select Guided Setup
  - Select the disk(s) you intend to use.
  - For existing Partitions and other partitions select "Remove if even not needed"
  - Select "Enable Logical Volume Management (LVM)"
  - File System select "XFS". Don't select separate LVM volume for home. K3S stores all its data in `/var/lib/rancher/k3s`. Leave Swap LVM Volume selected.

    *Note: If you are not familiar with Btrfs and enable snapshots, you may find that your drives will fill up.*

  - Back at the Partition summary screen, select Expert Partitioner -> start with current proposal.
  - I use CIS level 2 partition requirements for my linux disk layouts (some sizes are guestimations but work).  Always easier to do at install rather than after and the makes linux more durable.  The following is the disk layout for K3 (by priority) and can be modified for you primary OS disk:

    |Name|Mount Point|Size|
    |--|--|--|
    |dev_shm|/dev/shm|8GiB|
    |swap|swap|8GiB|
    |var_log_audit|/var/log/audit|2GiB|
    |var_tmp|/var/tmp|8-20GiB|
    |tmp|/tmp|8-20GiB|
    |var_log|/var/log|8-20GiB|
    |home|/home|2-20GiB|
    |root|/|70-100GiB|
    |var|/var|150+GiB|

    *Note: If you have more than one disk, keep the "OS" disk it's own VG (Volume Group) then the others to a data VG and create a LV for K3s storage at `/var/lib/rancher`.  I found it better to build the OS partitioning around K3S's defaults then keep modifying K3S configs to meet your own custom layout.*
    
    *Note: the default location that persistant data (PVs) will be stored is `/var/lib/rancher/k3s/data` so make the var (or sub folder) large enough to store any amount of persistant data.  I recommend at least 100GiB or more.*
    - In Expert partitioner, select "LVM Volume Groups, and select "root" and resize (at top left of screen there is Device->Resize) to custom size as above. 
    - Create the above layout.
- Select your time zone.  You can change the NTP servers if needed.
- Create local user with admin
- On the Installation Settings (summary) screen:
  - select Software
    - Click Details at the lower left.
    - Click the Search tab in the upper left.
    - Search and select:
      - open-iscsi 
      - nfs-client
  - Select Security
    - Major Linux Security Module, select selinux
  - Under Security, make sure ssh service is enabled and the firewall port is open.
  - Select Network Configuration
    - Set a static IP if so desired.
    - On Hostname/DNS tab, set hostname and set hostname via dhcp NO.
  - Under the Network Configuration section, switch to Network Manager network configuration
  - Use firewalld (default on newer versions and is not a selectable option).

## Configure Local Firewall
Next configure firewalld:

For Single node:
```
sudo firewall-cmd --remove-service=dhcpv6-client --permanent
sudo firewall-cmd --add-service=kube-apiserver --permanent
sudo firewall-cmd --add-port=4443/tcp --permanent
sudo firewall-cmd --add-port=7472/tcp --permanent # Metallb Monitoring
sudo firewall-cmd --add-port=7473/tcp --permanent # Metallb Monitoring
sudo firewall-cmd --add-port=8443/tcp --permanent # Don't remember what this was
sudo firewall-cmd --add-port=9100/tcp --permanent # For Prometheus node exporter
sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 # pods
sudo firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 # services
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload
```

For multi node:
```
sudo firewall-cmd --remove-service=dhcpv6-client --permanent
sudo firewall-cmd --add-service=kube-apiserver --permanent
sudo firewall-cmd --add-port=4443/tcp --permanent
sudo firewall-cmd --add-port=7472/tcp --permanent # Metallb Monitoring
sudo firewall-cmd --add-port=7473/tcp --permanent # Metallb Monitoring
sudo firewall-cmd --add-port=8443/tcp --permanent
sudo firewall-cmd --add-port=8472/udp --permanent # For Flannel
sudo firewall-cmd --add-port=10250/tcp --permanent
sudo firewall-cmd --add-port=2379-2380/tcp --permanent  # etcd
sudo firewall-cmd --add-port=9100/tcp --permanent # For Prometheus node exporter
sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 # pods
sudo firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 # services
firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload
```

See:
https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-server-nodes

## Install K3S
Use the following to install without the default load balancer (servicelb) and ingress controller (traefik) since we will be using the more common load balancer called metallb and ingress controller by nginx:

`curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable servicelb,traefik" sh -`

## Enable SELinux Support

https://docs.k3s.io/advanced?_highlight=selinux#selinux-support


`sudo systemctl edit --full k3s.service`

Find:

```
...
ExecStart=/usr/local/bin/k3s \
    server \
        '--disable' \
        'servicelb,traefik' \
        '--selinux' \  # <-- Add this
...
```
save `CTRL+O ENTER`, quit `CTRL+X`

Restart the K3S service:

`sudo systemctl restart k3s.service`


## Change Permissions on System kubeconfig File
To allow for local kubectl commands with a regular user, change the permissions of the k3s.yaml file:

`sudo chmod 755 /etc/rancher/k3s/k3s.yaml`

*Note: The permissions of this file will reset after reboot.*

To set permanently, edit the systemd unit file:

`sudo systemctl edit --full k3s.service`

Find:

```
...
ExecStart=/usr/local/bin/k3s \
    server \
        '--disable' \
        'servicelb,traefik' \
        '--write-kubeconfig-mode' \  # <-- Add this
        '644' \                      # <-- And this
...
```
save `CTRL+O ENTER`, quit `CTRL+X`

Restart the K3S service:

`sudo systemctl restart k3s.service`

## Optional: Configure K3s to use for etcd
*Note: You can specify it in the install command, but I found it works better after the intial install.*

If you have a cluster of K3S nodes larger than 3 nodes (but odd number) you can use etcd as a distributed/redundant database (sorta).

`sudo systemctl edit --full k3s.service`

Find:

```
...
ExecStart=/usr/local/bin/k3s \
    server \
        '--cluster-init' \  #  <-- Add this line
        '--disable' \
        'servicelb,traefik' \
...
```
save `CTRL+O ENTER`, quit `CTRL+X`

Restart the K3S service:

`sudo systemctl restart k3s.service`

## Optional: Edit the metrics-server deployment
I have had problems with remote kubectl configurations/connections saying it can't get metrics. I think it was with a single K3s node deployment architecture. You can edit the port that the metric server runs on so that you don't need to edit default stuff on the remote client. Basically replace port 10250 with 4443 and allow insecure connections and host network access (create ports on the host's IP).

`kubectl edit deployment.apps -n kube-system metrics-server`

Find the following contexts and set it as follows:

```
...
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-insecure-tls=true
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
...
        name: metrics-server
        ports:
        - containerPort: 4443
          hostPort: 4443
          name: https
          protocol: TCP
...
      dnsPolicy: ClusterFirst
      hostNetwork: true
      priorityClassName: system-node-critical
...
```

## Optional: Add more control-planes and worker nodes

1. Follow:
   1. [Install OS](#install-os)
   2. [Configure the firewall](#configure-local-firewall)
2. On the primary node, get the cluster's secret token with:

   `sudo cat /var/lib/rancher/k3s/server/node-token`

   Save that token for adding more nodes later on.
3. To install a worker node:

   `curl -sfL https://get.k3s.io | K3S_URL=https://node0.home.local:6443 K3S_TOKEN=[token goes here] sh -`

   To install a control-plane node with the etcd:

   `curl -sfL https://get.k3s.io | K3S_TOKEN=[token goes here] INSTALL_K3S_EXEC="--disable servicelb,traefik" sh -s - server --server https://node0.home.local:6443`


# Configure Management Computer
## Install kubectl
See:
https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

1.  `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`
2.  `curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"`
3.  `echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check`
4.  `sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl`
5.  `kubectl version --client`

## Install helm
Helm manages most the yaml files that go along with an application deployment.

*See:*
https://helm.sh/docs/intro/install/

1.  `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`
2.  `chmod 700 get_helm.sh`
3.  `./get_helm.sh`
4.  `helm version`

*Note: Some Linux distros have helm in the package system now.  OpenSuSE 15.6 has it in the package system.  `sudo zypper install helm`*

## Optional: Install k9s
K9s is a visual management tool that runs in the CLI.  I like k9s.  Easy, intuative tool for managing a cluster.
*See:*
https://github.com/derailed/k9s

`curl -sS https://webinstall.dev/k9s | bash`

*Note: Some Linux distros have k9s in the package system now.  OpenSuSE 15.6 has it in the package system.  `sudo zypper install k9s`*

## Get kubectl config from cluster
1. Make the config directly:

   `mkdir -p ~/.kube`

2. Get the config from the/a k3s node and put it in your local .kube foler in your home directory.  K9s also uses this kubectl config by default.

   `scp username@your.k3sserver.fqdn.or.ip:/etc/rancher/k3s/k3s.yaml ~/.kube/config`

   *Note: See [above](#change-permissions-on-system-kubeconfig-file) if having issues*

3. The "kubeconfig" as it is called from the k3s node will have a server IP of `127.0.0.1`. Replace the localhost address (`127.0.0.1`) with your node's FQDN. If you don't want to run sed, just use a text editor to replace `127.0.0.1` with your nodes DNS fqdn.

   `sed -i 's/127.0.0.1/your.k3sserver.fqdn.or.ip/g' ~/.kube/config`

   Or to use vim/nano:

   `vim ~/.kube/config`

   `nano ~/.kube/config`

*Note: For multiple kubeconfigs, see [merge-kuebconfigs.sh](tools/scripts/merge-kubeconfigs.sh)*  

# Next Steps Before Application Deployments
At this point about everything can be done from your management computer.  Next we need to install a few extra components (since we removed trafik and servicelb):

1. (optional) [Install secrets-generator](#install-secrets-generator)
2. (optional) [Install Prometheus Stack](#install-prometheus-stack) (so CRDs will be available for other deployments)
3. [Install metallb](#install-metallb) - this is really needed to get your service loadbalancer endpoints onto the network.
4. [Install an ingress controller (nginx)](#install-nginx-ingress-controller)
5. [Install longhorn for multi-node deployments without network storage](#optional-install-longhorn)

## Install Secrets Generator
I use secrets generator since to keep from using the same password everywhere.  This is not the most seure method.  A better way would be using a secure secrets system that is usually too advanced for a home lab setup.

See [install-secrets-generator.sh](security/secrets-generator/install-secrets-generator.sh)
```
helm upgrade --install secret-generator kubernetes-secret-generator \
  --repo https://helm.mittwald.de \
  --namespace secret-generator --create-namespace
```

example usage:

This (what you apply):
```
---
apiVersion: v1
kind: Secret
metadata:
  name: grafana-secrets
  namespace: monitoring
  annotations:
    secret-generator.v1.mittwald.de/autogenerate: admin-password
    secret-generator.v1.mittwald.de/length: "20"
stringData:
  admin-user: admin
```

Creates (what you get):
```
---
apiVersion: v1
kind: Secret
metadata:
  name: grafana-secrets
  namespace: monitoring
  annotations:
    secret-generator.v1.mittwald.de/autogenerate: admin-password
    secret-generator.v1.mittwald.de/length: "20"
    secret-generator.v1.mittwald.de/autogenerate-generated-at: "[some date]" 
    secret-generator.v1.mittwald.de/secure: "yes"
    secret-generator.v1.mittwald.de/type: string
stringData:
  admin-user: admin # This would be base64 encoded when viewing it
  admin-password: [random 20 character password]  # This would be base64 encoded when viewing it
```
I am using this secret for the next install, so if you are doing the next install, make sure to create [secret-grafana.yaml](monitoring/prometheus-stack/secret-grafana.yaml).

## Install Prometheus Stack
Install the Prometheus monitoring stack first so that the CRDs are available for other deployments. Do this now so you don't need to redeploy the others.

Create [values-monitoring-stack.yaml](monitoring/prometheus-stack/values-monitoring-stack.yaml) with:
```
---
grafana:
  admin:
    existingSecret: grafana-secrets
    userKey: admin-user
    passwordKey: admin-password
prometheus:
  # This is needed to scrape all data.
  prometheusSpec:
    ruleSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    probeSelectorNilUsesHelmValues: false
    scrapeConfigSelectorNilUsesHelmValues: false
```
This above tells the prometheus instance to scrape everything by default.  Without it, Prometheus will only scrape things with the release label from the helm chart deployment.

Run the following to install ([install-monitoring-stack.sh](monitoring/prometheus-stack/install-monitoring-stack.sh)):
```
helm upgrade --install kube-prometheus-stack kube-prometheus-stack \
  --repo  https://prometheus-community.github.io/helm-charts \
  --namespace monitoring --create-namespace \
  -f ./values-monitoring-stack.yaml \
  --version 67.2.0 \
  --wait
```
You will need to go back and configure ingress and things like that in the future.

## Install MetalLB
Hopefully you have thought about what IP ranges you will need. Next we will define what IP pools your lab will use. Any 'external' services set to 'LoadBalancer' services will need a real IP with L2 advertisement (otherwise ARP won't be updated).

create a metallb_config.yaml file with the following:

```
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: home-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.0.25-192.168.0.150
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: home-pool-static
  namespace: metallb-system
spec:
  addresses:
  - 192.168.0.15-192.168.0.19
  autoAssign: false
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: home-l2a
  namespace: metallb-system
spec:
  ipAddressPools:
  - home-pool
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: home-l2a-static
  namespace: metallb-system
spec:
  ipAddressPools:
  - home-pool-static
```

Above two IP pool are created on the same network as the nodes.  One with 'autoAssign: true' which will...auto hand out addresses when that pool is used, and the other is set to 'autoAssign: false' which means the pool need an explicit IP assignment.  Make sure that both pools have an L2 advertisement selection.  They could probably be combined into one but I created the at different times.

To install/deploy MetalLB (from your management computer), I have a script that does the following:

Before running the following command, make sure to create:

[values-metallb.yaml](environment/metallb/values-metallb.yaml)

That values file configures monitoring for metallb.  It has nice things like IP pool monitoring. 

When ready [install metallb](environment/metallb/install-metallb.sh) (if you don't want monitoring leave of the -f line)

```
helm upgrade --install metallb-system metallb \
  --repo https://metallb.github.io/metallb \
  --namespace metallb-system --create-namespace \
  -f ./values-metallb.yaml \
  --version 0.14.9
sleep 60
kubectl apply -f metallb_config.yaml
```

*Note: Notice in some of these helm chart I deploy the version is explicitly specified.  The version setting keeps kubernetes from going out and trying to download the latest version of the helm chart.  I recommend finding the version of the helm chart that is compatiable with your cluster version.  It is good to read the release notes.  Some new charts may not work like an old chart.*

## Install Nginx Ingress Controller
The out-of-the-box nginx ingress controller is sufficient for now. To install/deploy nginx, run the following:

```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

## Optional: Install Longhorn
Longhorn is a distributed storage system.  You do not need this if you only have one node.  I have it running on all my nodes to provide storage (PVs) to the applications.

*See:*
https://longhorn.io/docs/1.5.0/deploy/install/install-with-helm/
https://docs.k3s.io/storage#setting-up-longhorn

```
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.1
```

## Further Installs
1. external-dns - Auto update your local DNS when new services are deployed.
2. cert-manager - Auto hand out certs to things like services.
3. [step-certificates and step-issuer](environment/step-ca/readme-step-ca.md) - Auto hand out certs from your own two-tier CA. Allows you to install one root cert on all your devices.

