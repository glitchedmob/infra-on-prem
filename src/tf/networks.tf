locals {
  network_cidrs = {
    home       = "192.168.1.0/24"
    management = "10.0.0.0/24"
    sgfdevs    = "10.20.4.0/22"
  }

  network_vlans = {
    home       = 10
    management = 11
    sgfdevs    = 13
  }
}

module "home_network" {
  source = "./modules/network"

  providers = {
    routeros.router = routeros.router
    routeros.switch = routeros.switch
  }

  network_name            = "home"
  vlan_id                 = local.network_vlans.home
  router_parent_interface = routeros_interface_bridge.router_bridge.name
  switch_parent_interface = routeros_interface_bridge.switch_bridge.name
  network_cidr            = local.network_cidrs.home
  gateway_ip              = cidrhost(local.network_cidrs.home, 1)

  dhcp_pool_start = cidrhost(local.network_cidrs.home, 2)
  dhcp_pool_end   = cidrhost(local.network_cidrs.home, 254)

  switch_bridge_name = routeros_interface_bridge.switch_bridge.name

  switch_tagged_ports = [
    routeros_interface_bridge_port.switch_router.interface
  ]

  switch_access_ports = [
    routeros_interface_bridge_port.switch_home_devices.interface,
    routeros_interface_bridge_port.arm_node_01.interface,
    routeros_interface_bridge_port.x86_node_03.interface,
    routeros_interface_bridge_port.switch_unused3.interface
  ]

  router_bridge_name = routeros_interface_bridge.router_bridge.name

  router_tagged_ports = [
    routeros_interface_bridge_port.router_switch.interface
  ]

  router_access_ports = [
    routeros_interface_bridge_port.router_home_devices.interface,
    routeros_interface_bridge_port.router_wap.interface,
    routeros_interface_bridge_port.router_unused.interface
  ]

  dns_records = {}
}

module "management_network" {
  source = "./modules/network"

  providers = {
    routeros.router = routeros.router
    routeros.switch = routeros.switch
  }

  network_name            = "management"
  vlan_id                 = local.network_vlans.management
  router_parent_interface = routeros_interface_bridge.router_bridge.name
  switch_parent_interface = routeros_interface_bridge.switch_bridge.name
  network_cidr            = local.network_cidrs.management
  gateway_ip              = cidrhost(local.network_cidrs.management, 1)

  dhcp_pool_start = cidrhost(local.network_cidrs.management, 100)
  dhcp_pool_end   = cidrhost(local.network_cidrs.management, 254)


  router_bridge_name = routeros_interface_bridge.router_bridge.name

  router_tagged_ports = [
    routeros_interface_bridge_port.router_switch.interface
  ]

  router_access_ports = []

  switch_bridge_name = routeros_interface_bridge.switch_bridge.name

  switch_tagged_ports = [
    routeros_interface_bridge_port.switch_router.interface,
    routeros_interface_bridge_port.x86_node_01.interface,
    routeros_interface_bridge_port.x86_node_02.interface,
  ]

  switch_access_ports = []

  dns_records = {
    "x86-node-01" = {
      ip      = cidrhost(local.network_cidrs.management, 2)
      comment = "X86 Proxmox Node 01"
    }
    "x86-node-02" = {
      ip      = cidrhost(local.network_cidrs.management, 3)
      comment = "X86 Proxmox Node 02"
    }
    "x86-node-03" = {
      ip      = cidrhost(local.network_cidrs.management, 4)
      comment = "X86 Proxmox Node 03"
    }
    "arm-node-01" = {
      ip      = cidrhost(local.network_cidrs.management, 5)
      comment = "ARM Proxmox Node 01"
    }
    "arm-node-02" = {
      ip      = cidrhost(local.network_cidrs.management, 6)
      comment = "ARM Proxmox Node 02"
    }
  }
}

module "sgfdevs_network" {
  source = "./modules/network"

  providers = {
    routeros.router = routeros.router
    routeros.switch = routeros.switch
  }

  network_name            = "sgfdevs"
  vlan_id                 = local.network_vlans.sgfdevs
  router_parent_interface = routeros_interface_bridge.router_bridge.name
  switch_parent_interface = routeros_interface_bridge.switch_bridge.name
  network_cidr            = local.network_cidrs.sgfdevs
  gateway_ip              = cidrhost(local.network_cidrs.sgfdevs, 1)

  dhcp_pool_start = cidrhost(local.network_cidrs.sgfdevs, 100)
  dhcp_pool_end   = cidrhost(local.network_cidrs.sgfdevs, 1022)

  router_bridge_name = routeros_interface_bridge.router_bridge.name

  router_tagged_ports = [
    routeros_interface_bridge_port.router_switch.interface
  ]

  router_access_ports = []

  switch_bridge_name = routeros_interface_bridge.switch_bridge.name

  switch_tagged_ports = [
    routeros_interface_bridge_port.switch_router.interface,
    routeros_interface_bridge_port.x86_node_01.interface,
    routeros_interface_bridge_port.x86_node_02.interface,
  ]

  switch_access_ports = []

  dns_records = {}
}
