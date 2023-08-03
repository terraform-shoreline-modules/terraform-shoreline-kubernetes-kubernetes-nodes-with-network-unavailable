resource "shoreline_notebook" "kubernetes_nodes_with_network_unavailable" {
  name       = "kubernetes_nodes_with_network_unavailable"
  data       = file("${path.module}/data/kubernetes_nodes_with_network_unavailable.json")
  depends_on = [shoreline_action.invoke_pod_info,shoreline_action.invoke_firewall_security_check,shoreline_action.invoke_network_connectivity_check,shoreline_action.invoke_routing_tables_updater,shoreline_action.invoke_adjust_network_policies]
}

resource "shoreline_file" "pod_info" {
  name             = "pod_info"
  input_file       = "${path.module}/data/pod_info.sh"
  md5              = filemd5("${path.module}/data/pod_info.sh")
  description      = "Check the status of the Kubernetes network components"
  destination_path = "/agent/scripts/pod_info.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "firewall_security_check" {
  name             = "firewall_security_check"
  input_file       = "${path.module}/data/firewall_security_check.sh"
  md5              = filemd5("${path.module}/data/firewall_security_check.sh")
  description      = "Firewall or security group settings blocking network traffic on the affected nodes"
  destination_path = "/agent/scripts/firewall_security_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "network_connectivity_check" {
  name             = "network_connectivity_check"
  input_file       = "${path.module}/data/network_connectivity_check.sh"
  md5              = filemd5("${path.module}/data/network_connectivity_check.sh")
  description      = "Routing issues in the cluster"
  destination_path = "/agent/scripts/network_connectivity_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "routing_tables_updater" {
  name             = "routing_tables_updater"
  input_file       = "${path.module}/data/routing_tables_updater.sh"
  md5              = filemd5("${path.module}/data/routing_tables_updater.sh")
  description      = "Check if the routing tables are correctly configured to ensure that the nodes can communicate with each other."
  destination_path = "/agent/scripts/routing_tables_updater.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "adjust_network_policies" {
  name             = "adjust_network_policies"
  input_file       = "${path.module}/data/adjust_network_policies.sh"
  md5              = filemd5("${path.module}/data/adjust_network_policies.sh")
  description      = "Check for any network security policies that may be blocking traffic between nodes and adjust them accordingly."
  destination_path = "/agent/scripts/adjust_network_policies.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_pod_info" {
  name        = "invoke_pod_info"
  description = "Check the status of the Kubernetes network components"
  command     = "`chmod +x /agent/scripts/pod_info.sh && /agent/scripts/pod_info.sh`"
  params      = []
  file_deps   = ["pod_info"]
  enabled     = true
  depends_on  = [shoreline_file.pod_info]
}

resource "shoreline_action" "invoke_firewall_security_check" {
  name        = "invoke_firewall_security_check"
  description = "Firewall or security group settings blocking network traffic on the affected nodes"
  command     = "`chmod +x /agent/scripts/firewall_security_check.sh && /agent/scripts/firewall_security_check.sh`"
  params      = ["NODE_NAME"]
  file_deps   = ["firewall_security_check"]
  enabled     = true
  depends_on  = [shoreline_file.firewall_security_check]
}

resource "shoreline_action" "invoke_network_connectivity_check" {
  name        = "invoke_network_connectivity_check"
  description = "Routing issues in the cluster"
  command     = "`chmod +x /agent/scripts/network_connectivity_check.sh && /agent/scripts/network_connectivity_check.sh`"
  params      = ["POD_NAME","NAMESPACE"]
  file_deps   = ["network_connectivity_check"]
  enabled     = true
  depends_on  = [shoreline_file.network_connectivity_check]
}

resource "shoreline_action" "invoke_routing_tables_updater" {
  name        = "invoke_routing_tables_updater"
  description = "Check if the routing tables are correctly configured to ensure that the nodes can communicate with each other."
  command     = "`chmod +x /agent/scripts/routing_tables_updater.sh && /agent/scripts/routing_tables_updater.sh`"
  params      = ["DESTINATION_NETWORK","POD_NAME","NAMESPACE","GATEWAY_IP"]
  file_deps   = ["routing_tables_updater"]
  enabled     = true
  depends_on  = [shoreline_file.routing_tables_updater]
}

resource "shoreline_action" "invoke_adjust_network_policies" {
  name        = "invoke_adjust_network_policies"
  description = "Check for any network security policies that may be blocking traffic between nodes and adjust them accordingly."
  command     = "`chmod +x /agent/scripts/adjust_network_policies.sh && /agent/scripts/adjust_network_policies.sh`"
  params      = ["NAMESPACE","POLICY_FILE"]
  file_deps   = ["adjust_network_policies"]
  enabled     = true
  depends_on  = [shoreline_file.adjust_network_policies]
}

