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