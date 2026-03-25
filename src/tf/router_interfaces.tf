resource "routeros_interface_bridge" "router_bridge" {
  provider       = routeros.router
  name           = "bridge"
  admin_mac      = "F4:1E:57:90:34:1C"
  auto_mac       = false
  vlan_filtering = true
}

resource "routeros_interface_list" "router_wan" {
  provider = routeros.router
  name     = "WAN"
}

resource "routeros_interface_list" "router_lan" {
  provider = routeros.router
  name     = "LAN"
}

resource "routeros_interface_list" "router_management" {
  provider = routeros.router
  name     = "MGMT"
}

resource "routeros_interface_list" "router_project_vlans" {
  provider = routeros.router
  name     = "PROJECT_VLANS"
}

resource "routeros_interface_bridge_port" "router_wap" {
  provider  = routeros.router
  bridge    = routeros_interface_bridge.router_bridge.name
  interface = "ether2"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "router_home_devices" {
  provider  = routeros.router
  bridge    = routeros_interface_bridge.router_bridge.name
  interface = "ether3"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "router_switch" {
  provider  = routeros.router
  bridge    = routeros_interface_bridge.router_bridge.name
  interface = "ether4"
  pvid      = 10
}

resource "routeros_interface_bridge_port" "router_unused" {
  provider  = routeros.router
  bridge    = routeros_interface_bridge.router_bridge.name
  interface = "ether5"
  pvid      = 10
}

resource "routeros_interface_list_member" "router_ether1_wan" {
  provider  = routeros.router
  list      = routeros_interface_list.router_wan.name
  interface = "ether1"
}

resource "routeros_interface_list_member" "router_home_vlan_lan" {
  provider  = routeros.router
  list      = routeros_interface_list.router_lan.name
  interface = module.home_network.vlan_interface_name
}

resource "routeros_interface_list_member" "router_management_vlan_mgmt" {
  provider  = routeros.router
  list      = routeros_interface_list.router_management.name
  interface = module.management_network.vlan_interface_name
}

resource "routeros_interface_list_member" "router_sgfdevs_vlan_projects" {
  provider  = routeros.router
  list      = routeros_interface_list.router_project_vlans.name
  interface = module.sgfdevs_network.vlan_interface_name
}

resource "routeros_interface_list_member" "router_lz_vlan_projects" {
  provider  = routeros.router
  list      = routeros_interface_list.router_project_vlans.name
  interface = module.lz_network.vlan_interface_name
}
