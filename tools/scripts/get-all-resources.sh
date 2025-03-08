#!/bin/bash
# Links
# https://stackoverflow.com/questions/43225591/selecting-array-elements-with-the-custom-columns-kubernetes-cli-output
# https://stackoverflow.com/questions/47691479/listing-all-resources-in-a-namespace
# https://regex101.com/r/tQ7jF1/1

DNSREGEX="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-\_]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"



if [ -z "$1" ]; then
    kubectl get -A $(kubectl api-resources --namespaced=true --verbs=list --no-headers -o name | egrep -v 'events|nodes|packagemanifests' | paste -s -d, - ) --ignore-not-found -o=custom-columns="Namespace:.metadata.namespace,Kind:.kind,Name:.metadata.name,Created:.metadata.creationTimestamp,Helm Chart:.metadata.labels.helm\.sh\/chart,Helm Release Name:.metadata.annotations.meta\.helm\.sh\/release-name,Part Of:.metadata.labels.app\.kubernetes\.io\/part-of" | egrep -v "Error|Warning|Deprecat"
else
    if [[ $1 =~ $DNSREGEX ]];then
        kubectl get -n $1 $(kubectl api-resources --namespaced=true --verbs=list --no-headers -o name | egrep -v 'events|nodes|packagemanifests' | paste -s -d, - ) --ignore-not-found -o=custom-columns="Namespace:.metadata.namespace,Kind:.kind,Name:.metadata.name,Created:.metadata.creationTimestamp,Helm Chart:.metadata.labels.helm\.sh\/chart,Helm Release Name:.metadata.annotations.meta\.helm\.sh\/release-name,Part Of:.metadata.labels.app\.kubernetes\.io\/part-of" | egrep -v "Error|Warning|Deprecat"
    else
        echo "Invalid syntax!"
        echo "$1 is not DNS compliant."
        echo "Usage: $0 [namespace]"
    fi
    
fi