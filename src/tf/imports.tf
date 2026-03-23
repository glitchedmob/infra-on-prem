import {
  to = routeros_interface_bridge.router_bridge
  id = "bridge"
}

import {
  to = routeros_interface_list.router_wan
  id = "WAN"
}

import {
  to = routeros_interface_list.router_lan
  id = "LAN"
}

import {
  to = routeros_interface_bridge_port.router_wap
  id = "*0"
}

import {
  to = routeros_interface_bridge_port.router_home_devices
  id = "*1"
}

import {
  to = routeros_interface_bridge_port.router_switch
  id = "*2"
}

import {
  to = routeros_interface_bridge_port.router_unused
  id = "*3"
}

import {
  to = routeros_interface_list_member.router_ether1_wan
  id = "*2"
}

import {
  to = routeros_interface_list_member.router_home_vlan_lan
  id = "*3"
}

import {
  to = routeros_interface_bridge.switch_bridge
  id = "bridge"
}

import {
  to = routeros_interface_list.switch_wan
  id = "WAN"
}

import {
  to = routeros_interface_list.switch_lan
  id = "LAN"
}

import {
  to = routeros_interface_bridge_port.switch_router
  id = "*0"
}

import {
  to = routeros_interface_bridge_port.switch_unused3
  id = "*1"
}

import {
  to = routeros_interface_bridge_port.x86_node_01
  id = "*2"
}

import {
  to = routeros_interface_bridge_port.x86_node_02
  id = "*3"
}

import {
  to = routeros_interface_bridge_port.x86_node_03
  id = "*4"
}

import {
  to = routeros_interface_bridge_port.switch_home_devices
  id = "*5"
}

import {
  to = routeros_interface_bridge_port.arm_node_02
  id = "*6"
}

import {
  to = routeros_interface_bridge_port.switch_unused1
  id = "*7"
}

import {
  to = routeros_interface_bridge_port.switch_unused2
  id = "*8"
}

import {
  to = routeros_interface_bridge_port.arm_node_01
  id = "*9"
}

import {
  to = routeros_interface_list_member.switch_router_wan
  id = "*1"
}

import {
  to = routeros_interface_list_member.switch_home_devices_lan
  id = "*2"
}

import {
  to = routeros_interface_list_member.arm_node_02_lan
  id = "*3"
}

import {
  to = routeros_interface_list_member.switch_unused1_lan
  id = "*4"
}

import {
  to = routeros_interface_list_member.switch_unused2_lan
  id = "*5"
}

import {
  to = routeros_interface_list_member.arm_node_01_lan
  id = "*6"
}

import {
  to = routeros_interface_list_member.switch_unused3_lan
  id = "*7"
}

import {
  to = routeros_interface_list_member.x86_node_01_lan
  id = "*8"
}

import {
  to = routeros_interface_list_member.x86_node_02_lan
  id = "*9"
}

import {
  to = routeros_interface_list_member.x86_node_03_lan
  id = "*A"
}

import {
  to = routeros_ip_firewall_filter.input_established
  id = "*1"
}

import {
  to = routeros_ip_firewall_filter.input_invalid
  id = "*2"
}

import {
  to = routeros_ip_firewall_filter.input_icmp
  id = "*3"
}

import {
  to = routeros_ip_firewall_filter.input_loopback
  id = "*4"
}

import {
  to = routeros_ip_firewall_filter.input_drop_non_lan
  id = "*5"
}

import {
  to = routeros_ip_firewall_filter.forward_ipsec_in
  id = "*6"
}

import {
  to = routeros_ip_firewall_filter.forward_ipsec_out
  id = "*7"
}

import {
  to = routeros_ip_firewall_filter.forward_fasttrack
  id = "*8"
}

import {
  to = routeros_ip_firewall_filter.forward_established
  id = "*9"
}

import {
  to = routeros_ip_firewall_filter.forward_invalid
  id = "*A"
}

import {
  to = routeros_ip_firewall_filter.forward_wan_drop
  id = "*B"
}

import {
  to = routeros_ip_firewall_nat.masquerade
  id = "*1"
}

# =============================================================================
# Router System Resources
# =============================================================================

import {
  to = routeros_system_clock.router_clock
  id = "system.clock"
}

import {
  to = routeros_tool_mac_server.router_mac_server
  id = "tool.mac-server"
}

import {
  to = routeros_dns_record.router_lan
  id = "router.lan"
}

# =============================================================================
# Switch System Resources
# =============================================================================

import {
  to = routeros_system_clock.switch_clock
  id = "system.clock"
}

import {
  to = routeros_ip_pool.router_default_pool
  id = "default-dhcp"
}

import {
  to = routeros_ip_address.router_bridge_ip
  id = "*1"
}

import {
  to = routeros_ip_dhcp_client.router_ether1
  id = "*1"
}

import {
  to = routeros_ip_dhcp_server.router_defconf
  id = "defconf"
}

import {
  to = routeros_ip_dhcp_server_network.router_defconf_net
  id = "*1"
}
