resource "routeros_ip_pool" "router_default_pool" {
  provider = routeros.router
  name     = "default-dhcp"
  ranges   = ["192.168.88.10-192.168.88.254"]
}

resource "routeros_ip_address" "router_bridge_ip" {
  provider  = routeros.router
  address   = "192.168.88.1/24"
  interface = routeros_interface_bridge.router_bridge.name
  network   = "192.168.88.0"
}

resource "routeros_ip_dhcp_client" "router_ether1" {
  provider  = routeros.router
  interface = "ether1"
  comment   = "defconf"
}

resource "routeros_ip_dhcp_server" "router_defconf" {
  provider                  = routeros.router
  name                      = "defconf"
  interface                 = routeros_interface_bridge.router_bridge.name
  address_pool              = routeros_ip_pool.router_default_pool.name
  dynamic_lease_identifiers = "client-mac,client-id"
}

resource "routeros_ip_dhcp_server_network" "router_defconf_net" {
  provider   = routeros.router
  address    = "192.168.88.0/24"
  gateway    = "192.168.88.1"
  dns_server = ["192.168.88.1"]
  netmask    = "24"
}

resource "routeros_ip_dhcp_server_lease" "switch_static" {
  provider     = routeros.router
  address      = "192.168.1.2"
  mac_address  = "18:FD:74:6A:E4:54"
  block_access = false
  comment      = "managedBy=terraform,network=home"
}

# Switch IP is managed outside the module (static IP assignment)
resource "routeros_ip_address" "switch_vlan_ip" {
  provider  = routeros.switch
  address   = "192.168.1.2/24"
  interface = module.home_network.switch_vlan_interface_name
  network   = "192.168.1.0"
}

resource "routeros_ip_address" "switch_management_vlan_ip" {
  provider  = routeros.switch
  address   = "10.0.0.2/24"
  interface = module.management_network.switch_vlan_interface_name
  network   = "10.0.0.0"
}
