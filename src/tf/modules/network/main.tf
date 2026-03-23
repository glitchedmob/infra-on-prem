locals {
  # Use provided gateway or default to first usable IP in CIDR
  gateway_ip = var.gateway_ip != "" ? var.gateway_ip : cidrhost(var.network_cidr, 1)
}

# VLAN interface on router (Layer 3)
resource "routeros_interface_vlan" "vlan" {
  provider = routeros.router

  name      = "${var.network_name}-vlan-${var.vlan_id}"
  vlan_id   = var.vlan_id
  interface = var.router_parent_interface
  comment   = "managedBy=terraform,network=${var.network_name}"
}

resource "routeros_ip_pool" "dhcp_pool" {
  provider = routeros.router

  name    = "${var.network_name}-dhcp"
  ranges  = ["${var.dhcp_pool_start}-${var.dhcp_pool_end}"]
  comment = "managedBy=terraform,network=${var.network_name}"
}

resource "routeros_ip_address" "gateway" {
  provider = routeros.router

  address   = "${local.gateway_ip}/${split("/", var.network_cidr)[1]}"
  interface = routeros_interface_vlan.vlan.name
  comment   = "managedBy=terraform,network=${var.network_name},purpose=gateway"
}

resource "routeros_ip_dhcp_server" "dhcp" {
  provider = routeros.router

  name                      = var.network_name
  interface                 = routeros_interface_vlan.vlan.name
  address_pool              = routeros_ip_pool.dhcp_pool.name
  lease_time                = "1d"
  dynamic_lease_identifiers = "client-mac,client-id"
  comment                   = "managedBy=terraform,network=${var.network_name}"
}

resource "routeros_ip_dhcp_server_network" "dhcp_network" {
  provider = routeros.router

  address    = var.network_cidr
  gateway    = local.gateway_ip
  dns_server = [local.gateway_ip]
  netmask    = split("/", var.network_cidr)[1]
  comment    = "managedBy=terraform,network=${var.network_name}"
}
#
# # Firewall: jump from input chain to network-specific chain for organization
# resource "routeros_ip_firewall_filter" "input_jump" {
#   provider = routeros.router
#
#   chain       = "input"
#   action      = "jump"
#   jump_target = "onprem-${var.network_name}"
#   comment     = "managedBy=terraform,network=${var.network_name},purpose=inputJump"
#   src_address = var.network_cidr
# }
#
# # Network-specific firewall chain with DNS allow rules
# resource "routeros_ip_firewall_filter" "allow_dns_tcp" {
#   provider = routeros.router
#
#   chain       = "onprem-${var.network_name}"
#   action      = "accept"
#   protocol    = "tcp"
#   dst_port    = "53"
#   src_address = var.network_cidr
#   comment     = "managedBy=terraform,network=${var.network_name},purpose=allowDnsTcp"
# }
#
# resource "routeros_ip_firewall_filter" "allow_dns_udp" {
#   provider = routeros.router
#
#   chain       = "onprem-${var.network_name}"
#   action      = "accept"
#   protocol    = "udp"
#   dst_port    = "53"
#   src_address = var.network_cidr
#   comment     = "managedBy=terraform,network=${var.network_name},purpose=allowDnsUdp"
# }
#
# # Drop traffic to other internal networks (RFC1918) - prevents inter-VLAN routing
# resource "routeros_ip_firewall_filter" "drop_rfc1918" {
#   provider = routeros.router
#
#   chain       = "onprem-${var.network_name}"
#   action      = "drop"
#   dst_address = "10.0.0.0/8"
#   comment     = "managedBy=terraform,network=${var.network_name},purpose=dropRFC1918"
# }
#
# # Drop traffic to other internal networks (RFC1918) - 172.16.0.0/12
# resource "routeros_ip_firewall_filter" "drop_rfc1918_172" {
#   provider = routeros.router
#
#   chain       = "onprem-${var.network_name}"
#   action      = "drop"
#   dst_address = "172.16.0.0/12"
#   comment     = "managedBy=terraform,network=${var.network_name},purpose=dropRFC1918_172"
# }
#
# # Drop traffic to other internal networks (RFC1918) - 192.168.0.0/16
# resource "routeros_ip_firewall_filter" "drop_rfc1918_192" {
#   provider = routeros.router
#
#   chain       = "onprem-${var.network_name}"
#   action      = "drop"
#   dst_address = "192.168.0.0/16"
#   comment     = "managedBy=terraform,network=${var.network_name},purpose=dropRFC1918_192"
# }
#
# # Return statement for the network-specific chain (allow rules go before this, drop rules after)
# resource "routeros_ip_firewall_filter" "chain_return" {
#   provider = routeros.router
#
#   chain   = "onprem-${var.network_name}"
#   action  = "return"
#   comment = "managedBy=terraform,network=${var.network_name},purpose=chainReturn"
# }
#
# # NAT masquerade for internet access
# resource "routeros_ip_firewall_nat" "masquerade" {
#   provider = routeros.router
#
#   chain         = "srcnat"
#   action        = "masquerade"
#   src_address   = var.network_cidr
#   out_interface = "ether1"
#   comment       = "managedBy=terraform,network=${var.network_name},purpose=masquerade"
# }

resource "routeros_dns_record" "static" {
  provider = routeros.router

  for_each = var.dns_records

  name    = each.key
  type    = "A"
  address = each.value.ip
  ttl     = "30m"
  comment = each.value.comment != "" ? each.value.comment : "managedBy=terraform,name=${each.key}"
}

# Switch VLAN interface (separate from router VLAN - same VLAN ID, different device)
resource "routeros_interface_vlan" "switch_vlan" {
  provider = routeros.switch

  name      = "${var.network_name}-vlan-${var.vlan_id}"
  vlan_id   = var.vlan_id
  interface = var.switch_parent_interface
  comment   = "managedBy=terraform,network=${var.network_name}"
}

# Switch Layer 2 VLAN configuration (references existing bridge ports)
resource "routeros_interface_bridge_vlan" "switch_vlan_entry" {
  provider = routeros.switch

  bridge   = var.switch_bridge_name
  vlan_ids = [var.vlan_id]
  tagged   = concat(var.switch_tagged_ports, [var.switch_bridge_name])
  untagged = var.switch_access_ports
  comment  = "managedBy=terraform,network=${var.network_name}"
}

# Router Layer 2 VLAN configuration (references existing bridge ports)
resource "routeros_interface_bridge_vlan" "router_vlan_entry" {
  provider = routeros.router

  bridge   = var.router_bridge_name
  vlan_ids = [var.vlan_id]
  tagged   = concat(var.router_tagged_ports, [var.router_bridge_name])
  untagged = var.router_access_ports
  comment  = "managedBy=terraform,network=${var.network_name}"
}
