
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Nodes with Network Unavailable
---

This incident type involves nodes in a Kubernetes cluster that are experiencing network unavailability, meaning they are not accessible. This could be due to a misconfiguration, route exhaustion, or a physical problem with the network connection to the hardware. It is a high urgency incident that requires immediate attention to restore network connectivity to the affected nodes.

### Parameters
```shell
# Environment Variables

export SERVICE_NAME="PLACEHOLDER"

export NODE_NAME="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export DESTINATION_NETWORK="PLACEHOLDER"

export GATEWAY_IP="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export POLICY_FILE="PLACEHOLDER"
```

## Debug

### Check if Kubernetes nodes are available
```shell
kubectl get nodes
```

### Check the status of each Kubernetes node
```shell
kubectl describe nodes
```

### Check the network configuration of each Kubernetes node
```shell
kubectl describe nodes | grep -A 5 Addresses
```

### Check if there are any pods that are failing due to network issues
```shell
kubectl get pods --all-namespaces | grep -i error
```

### Check the status of the Kubernetes network components
```shell
kubectl get pod -n kube-system | grep kube-proxy

kubectl get pod -n kube-system | grep kube-dns
```

### Check if there are any network policies that could be blocking traffic
```shell
kubectl get networkpolicy --all-namespaces
```

### Check if there are any issues with the Kubernetes service
```shell
kubectl get service
```

### Check if there are any issues with the Kubernetes endpoint
```shell
kubectl get endpoints ${SERVICE_NAME}
```

### Check if there are any issues with the Kubernetes ingress
```shell
kubectl get ingress
```

### Firewall or security group settings blocking network traffic on the affected nodes
```shell
#!/bin/bash

# Define variables

NODE_NAME=${NODE_NAME}

# Check firewall settings

echo "Checking firewall settings on node $NODE_NAME in the current cluster..."

kubectl exec $NODE_NAME -n kube-system -- sh -c "iptables -L -n" | grep "Chain INPUT (policy DROP)"

if [ $? -eq 0 ]; then

    echo "Firewall settings are blocking incoming network traffic on node $NODE_NAME in the current cluster."

else

    echo "Firewall settings are not blocking incoming network traffic on node $NODE_NAME in the current cluster."

fi

# Check security group settings

echo "Checking security group settings on node $NODE_NAME in the current cluster..."

kubectl exec $NODE_NAME -n kube-system -- sh -c "ss -lntu" | grep "LISTEN"

if [ $? -eq 0 ]; then

    echo "Security group settings are allowing incoming network traffic on node $NODE_NAME in the current cluster."

else

    echo "Security group settings are not allowing incoming network traffic on node $NODE_NAME in the current cluster."

fi

```

### Routing issues in the cluster
```shell
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

```

## Repair

### Check if the routing tables are correctly configured to ensure that the nodes can communicate with each other.
```shell
bash
#!/bin/bash

# Set the namespace and pod name of the affected node

NAMESPACE=${NAMESPACE}

POD_NAME=${POD_NAME}

# Check the routing tables of the affected node

kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "ip route show"

# If the routing tables are incorrect, update them to enable communication between nodes

kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "ip route add ${DESTINATION_NETWORK} via ${GATEWAY_IP}"


```

### Check for any network security policies that may be blocking traffic between nodes and adjust them accordingly.
```shell
#!/bin/bash

# Set variables

NAMESPACE=${NAMESPACE}

# Check for network security policies

kubectl get networkpolicies -n $NAMESPACE

# Adjust network security policies

kubectl apply -f ${POLICY_FILE}.yaml -n $NAMESPACE


```