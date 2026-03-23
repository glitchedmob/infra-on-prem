locals {
  headscale_proxmox_nodes = toset(var.headscale_proxmox_nodes)
}

resource "headscale_user" "proxmox" {
  name         = "proxmox"
  force_delete = true
}

resource "terraform_data" "headscale_key_rotation" {
  input = var.headscale_key_rotation_version
}

resource "headscale_pre_auth_key" "proxmox" {
  for_each = local.headscale_proxmox_nodes

  user           = headscale_user.proxmox.id
  time_to_expire = "1h"
  reusable       = false
  ephemeral      = false
  acl_tags       = [var.headscale_proxmox_tag]

  lifecycle {
    replace_triggered_by = [terraform_data.headscale_key_rotation]
  }
}

resource "aws_ssm_parameter" "headscale_proxmox_auth_key" {
  for_each = local.headscale_proxmox_nodes

  name             = "${var.ssm_path_prefix}/${each.value}-auth-key"
  type             = "SecureString"
  description      = "Headscale pre-auth key for ${each.value}"
  value_wo         = headscale_pre_auth_key.proxmox[each.value].key
  value_wo_version = var.headscale_key_rotation_version
}
