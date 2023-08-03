bash
#!/bin/bash

# Set the namespace and pod name of the affected node

NAMESPACE=${NAMESPACE}

POD_NAME=${POD_NAME}

# Check the routing tables of the affected node

kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "ip route show"

# If the routing tables are incorrect, update them to enable communication between nodes

kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "ip route add ${DESTINATION_NETWORK} via ${GATEWAY_IP}"