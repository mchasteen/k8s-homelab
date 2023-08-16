#!/bin/bash
# https://stackoverflow.com/questions/52369247/namespace-stuck-as-terminating-how-i-removed-it

# Usage:
# echo "namespace-to-delete" | ./delete-namespace.sh

NAMESPACE=$(cat)

#echo $NAMESPACE
# Clean namespace

RESULT=`kubectl get namespace $NAMESPACE -o json | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" | kubectl replace --raw /api/v1/namespaces/$NAMESPACE/finalize -f -`

echo $RESULT | jq
