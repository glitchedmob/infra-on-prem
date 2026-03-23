output "vlan_interface_name" {
  description = "Name of the VLAN interface"
  value       = routeros_interface_vlan.vlan.name
}

output "vlan_id" {
  description = "VLAN ID"
  value       = var.vlan_id
}

output "gateway_ip" {
  description = "Gateway IP address for the network"
  value       = local.gateway_ip
}

output "network_cidr" {
  description = "Network CIDR block"
  value       = var.network_cidr
}

output "dhcp_pool_name" {
  description = "Name of the DHCP pool"
  value       = routeros_ip_pool.dhcp_pool.name
}

output "dhcp_server_name" {
  description = "Name of the DHCP server"
  value       = routeros_ip_dhcp_server.dhcp.name
}

output "firewall_chain_name" {
  description = "Name of the network-specific firewall chain"
  value       = "onprem-${var.network_name}"
}

output "switch_vlan_interface_name" {
  description = "Name of the switch VLAN interface"
  value       = routeros_interface_vlan.switch_vlan.name
}
