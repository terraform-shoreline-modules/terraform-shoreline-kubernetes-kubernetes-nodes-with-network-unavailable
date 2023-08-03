#!/bin/bash

# Define Kubernetes namespace and pod name

K8S_NAMESPACE=${NAMESPACE}

K8S_POD_NAME=${POD_NAME}

# Check if kubectl is installed

if ! command -v kubectl &> /dev/null

then

    echo "kubectl command could not be found"

    exit

fi

# Verify network connectivity to Kubernetes API server

echo "Testing network connectivity to Kubernetes API server..."

kubectl --namespace=$K8S_NAMESPACE exec $K8S_POD_NAME -- curl -s -I -m 5 https://kubernetes.default.svc.cluster.local >/dev/null 2>&1

if [ $? -ne 0 ]; then

    echo "Unable to connect to Kubernetes API server"

    exit

fi

# Verify network connectivity to other pods in the same namespace

echo "Testing network connectivity to other pods in the same namespace..."

POD_IP=$(kubectl --namespace=$K8S_NAMESPACE exec $K8S_POD_NAME -- ip route get 8.8.8.8 | awk '{print $7}')

for pod in $(kubectl --namespace=$K8S_NAMESPACE get pods -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}{end}' | grep -v $K8S_POD_NAME); do

    kubectl --namespace=$K8S_NAMESPACE exec $K8S_POD_NAME -- curl -s -I -m 5 http://$pod.$K8S_NAMESPACE.svc.cluster.local >/dev/null 2>&1

    if [ $? -eq 0 ]; then

        echo "Successfully connected to $pod"

    else

        echo "Unable to connect to $pod"

    fi

done