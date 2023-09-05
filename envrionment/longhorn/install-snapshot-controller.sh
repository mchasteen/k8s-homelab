#!/bin/bash
# https://longhorn.io/docs/archives/1.2.3/snapshots-and-backups/csi-snapshot-support/enable-csi-snapshot-support/

mkdir -p client/config/crd/

wget https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.2.2/client/config/crd/kustomization.yaml -O client/config/crd/kustomization.yaml
wget https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.2.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml -O client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
wget https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.2.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml -O client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
wget https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.2.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml -O client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml

kubectl kustomize client/config/crd | kubectl apply -f -


mkdir -p deploy/kubernetes/snapshot-controller/

wget https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.2.2/deploy/kubernetes/snapshot-controller/kustomization.yaml -O deploy/kubernetes/snapshot-controller/kustomization.yaml
wget https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.2.2/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml -O deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
wget https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.2.2/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml -O deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml

kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl apply -f -

kubectl apply -f volume-snapshot-class.yaml
