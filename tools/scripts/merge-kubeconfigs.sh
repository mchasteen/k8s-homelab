#!/bin/bash
# Usage:
#  This script is expecting cluster yaml files to be in the ~/.kube/clusters folder.
#  This script saves the current config file to a backup folder, but does not use the
#  current config file when merging.  Instead it merges all the yaml files in the
#  clusters folder and overwrites the kubeconfig with a single, merged file.
# Expecting:
#  yaml files in the ~/.kube/clusters folder.

if [ ! -d ~/.kube/clusters ]; then
    echo "Found ~/.kube/clusters folder missing."
    echo "Adding clusters folder."
    mkdir -p ~/.kube/clusters
fi

if [ -f ~/.kube/config ] && [ ! $(ls ~/.kube/clusters/*.yaml 1> /dev/null 2>&1) ]; then
    
    echo "Found current kubeconfig."
    echo "Backing up to:"
    echo "  ~/.kube/backups/config.backup$(date +"%Y%m%d%H%M%S")"
    # Create the backups and clusters folder if none exist.
    mkdir -p ~/.kube/{clusters,backups}

    # Save Current Context and Namespace
    SAVE_CONTEXT=$(kubectl config current-context)
    SAVE_NAMESPACE=$(kubectl config view --minify --output jsonpath='{..namespace}')

    # Backup Existing Config
    mv ~/.kube/config ~/.kube/backups/config.backup$(date +"%Y%m%d%H%M%S")
fi

if [ ! $(ls ~/.kube/clusters/*.yaml 1> /dev/null 2>&1) ]; then
    echo "Found config files:"
    ls ~/.kube/clusters/*.yaml | tr -d ''    
    
    # Concatenate all yaml files
    export KUBECONFIG=$(ls ~/.kube/clusters/*.yaml | tr -d '' | tr '\n' ':')
    
    # Create a temp file to store the kubeconfig
    touch ~/.kube/merged.config
    chmod 600 ~/.kube/merged.config
    kubectl config view --flatten=true > ~/.kube/merged.config

    # Move temp file to config
    mv ~/.kube/merged.config ~/.kube/config

    # Restore context and Namespace
    kubectl config use-context $SAVE_CONTEXT > /dev/null
    if [ -n "$SAVE_NAMESPACE" ]; then
        kubectl config set-context --current --namespace $SAVE_NAMESPACE
    fi

else
    echo "No kubeconfig yaml found in ~/.kube/clusters/"
fi



