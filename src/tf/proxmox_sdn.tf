locals {
  sdn_networks = {
    lz = {
      zone_id = "tnvlans"
      vnet_id = "lz"
      bridge  = "vmbr0"
      tag     = local.network_vlans.lz
      alias   = "lz network"
    }

    sgfdevs = {
      zone_id = "tnvlans"
      vnet_id = "sgfdevs"
      bridge  = "vmbr0"
      tag     = local.network_vlans.sgfdevs
      alias   = "sgfdevs network"
    }
  }

  proxmox_sdn_zones = {
    for zone_id in toset([for network in values(local.sdn_networks) : network.zone_id]) : zone_id => {
      bridge = one(distinct([for network in values(local.sdn_networks) : network.bridge if network.zone_id == zone_id]))
    }
  }
}

resource "proxmox_virtual_environment_sdn_zone_vlan" "this" {
  for_each = local.proxmox_sdn_zones

  id     = each.key
  bridge = each.value.bridge
}

resource "proxmox_virtual_environment_sdn_vnet" "this" {
  for_each = local.sdn_networks

  id    = each.value.vnet_id
  zone  = each.value.zone_id
  tag   = each.value.tag
  alias = try(each.value.alias, null)
}

resource "terraform_data" "proxmox_sdn_version" {
  input = local.sdn_networks
}

resource "proxmox_virtual_environment_sdn_applier" "this" {
  lifecycle {
    replace_triggered_by = [
      terraform_data.proxmox_sdn_version,
    ]
  }

  depends_on = [
    proxmox_virtual_environment_sdn_zone_vlan.this,
    proxmox_virtual_environment_sdn_vnet.this,
  ]
}
