resource "routeros_interface_bridge" "switch_bridge" {
  provider       = routeros.switch
  name           = "bridge"
  admin_mac      = "18:FD:74:6A:E4:54"
  auto_mac       = false
  vlan_filtering = true
}

resource "routeros_interface_list" "switch_wan" {
  provider = routeros.switch
  name     = "WAN"
}

resource "routeros_interface_list" "switch_lan" {
  provider = routeros.switch
  name     = "LAN"
}

resource "routeros_interface_bridge_port" "switch_router" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "ether1"
}

resource "routeros_interface_bridge_port" "switch_unused3" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp-sfpplus1"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "x86_node_01" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp-sfpplus2"
  pvid      = 11
}

resource "routeros_interface_bridge_port" "x86_node_02" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp-sfpplus3"
  pvid      = 11
}

resource "routeros_interface_bridge_port" "x86_node_03" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp-sfpplus4"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "switch_home_devices" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp1"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "arm_node_02" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp2"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "switch_unused1" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp3"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "switch_unused2" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp4"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "arm_node_01" {
  provider  = routeros.switch
  bridge    = routeros_interface_bridge.switch_bridge.name
  interface = "sfp5"
  pvid      = 10
}

resource "routeros_interface_list_member" "switch_router_wan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_wan.name
  interface = "ether1"
}

resource "routeros_interface_list_member" "switch_home_devices_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.switch_home_devices.interface
}

resource "routeros_interface_list_member" "arm_node_02_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.arm_node_02.interface
}

resource "routeros_interface_list_member" "switch_unused1_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.switch_unused1.interface
}

resource "routeros_interface_list_member" "switch_unused2_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.switch_unused2.interface
}

resource "routeros_interface_list_member" "switch_unused3_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.switch_unused3.interface
}

resource "routeros_interface_list_member" "x86_node_01_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.x86_node_01.interface
}

resource "routeros_interface_list_member" "x86_node_02_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.x86_node_02.interface
}

resource "routeros_interface_list_member" "x86_node_03_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.x86_node_03.interface
}

resource "routeros_interface_list_member" "arm_node_01_lan" {
  provider  = routeros.switch
  list      = routeros_interface_list.switch_lan.name
  interface = routeros_interface_bridge_port.arm_node_01.interface
}
