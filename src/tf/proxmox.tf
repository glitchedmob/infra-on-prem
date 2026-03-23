locals {
  pool_privileges = [
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit",
    "Sys.Audit",
    "VM.Allocate",
    "VM.Audit",
    "VM.Clone",
    "VM.Config.CDROM",
    "VM.Config.Cloudinit",
    "VM.Config.CPU",
    "VM.Config.Disk",
    "VM.Config.Memory",
    "VM.Config.Network",
    "VM.Config.Options",
    "VM.Migrate",
    "VM.PowerMgmt",
  ]

  pools = {
    sgfdevs = {
      comment         = "managedBy=terraform,team=sgfdevs"
      role_id         = "SgfdevsVmAdmin"
      role_privileges = local.pool_privileges
      users = [
        {
          user_id        = "sgfdevs-gha@pve"
          user_comment   = "managedBy=terraform,pool=sgfdevs,purpose=gha"
          token_name     = "gha"
          token_comment  = "managedBy=terraform,pool=sgfdevs,purpose=gha"
          token_ssm_path = "/homelab/proxmox/sgfdevs/gha-token"
        },
      ]
    }
  }

  proxmox_pools = { for pool_id, pool in local.pools : pool_id => { comment = pool.comment } }

  proxmox_roles = {
    for pool_id, pool in local.pools : pool.role_id => {
      privileges = pool.role_privileges
    }
  }

  pool_users = flatten([
    for pool_id, pool in local.pools : [
      for user in pool.users : merge(user, { pool_id = pool_id, role_id = pool.role_id })
    ]
  ])

  proxmox_users = {
    for user in local.pool_users : user.user_id => {
      comment = user.user_comment
    }
  }

  proxmox_user_tokens = {
    for user in local.pool_users : "${user.pool_id}_${user.user_id}_${user.token_name}" => {
      user_id    = user.user_id
      token_name = user.token_name
      comment    = user.token_comment
      ssm_path   = coalesce(try(user.token_ssm_path, ""), "")
    }
    if try(user.token_name, "") != ""
  }

  proxmox_user_acls = {
    for user in local.pool_users : user.user_id => [
      {
        path      = "/pool/${user.pool_id}"
        role_id   = user.role_id
        propagate = true
      }
    ]
  }

  proxmox_tokens_with_ssm = {
    for token_key, token in local.proxmox_user_tokens : token_key => token
    if coalesce(try(token.ssm_path, ""), "") != ""
  }
}

resource "proxmox_virtual_environment_pool" "this" {
  for_each = local.proxmox_pools

  pool_id = each.key
  comment = try(each.value.comment, null)
}

resource "proxmox_virtual_environment_role" "this" {
  for_each = local.proxmox_roles

  role_id    = each.key
  privileges = each.value.privileges
}

resource "proxmox_virtual_environment_user" "this" {
  for_each = local.proxmox_users

  user_id         = each.key
  comment         = try(each.value.comment, null)
  email           = try(each.value.email, null)
  enabled         = try(each.value.enabled, null)
  expiration_date = try(each.value.expiration_date, null)
  first_name      = try(each.value.first_name, null)
  last_name       = try(each.value.last_name, null)
  password        = try(each.value.password, null)
  groups          = try(each.value.groups, null)

  dynamic "acl" {
    for_each = try(local.proxmox_user_acls[each.key], [])
    content {
      path      = acl.value.path
      role_id   = acl.value.role_id
      propagate = try(acl.value.propagate, true)
    }
  }
}

resource "proxmox_virtual_environment_user_token" "this" {
  for_each = local.proxmox_user_tokens

  user_id               = each.value.user_id
  token_name            = each.value.token_name
  comment               = try(each.value.comment, null)
  expiration_date       = try(each.value.expiration_date, null)
  privileges_separation = try(each.value.privileges_separation, true)

  lifecycle {
    replace_triggered_by = [terraform_data.proxmox_token_rotation]
  }

  depends_on = [proxmox_virtual_environment_user.this]
}

resource "terraform_data" "proxmox_token_rotation" {
  input = var.proxmox_token_rotation_version
}

resource "aws_ssm_parameter" "proxmox_user_token" {
  for_each = local.proxmox_tokens_with_ssm

  name             = each.value.ssm_path
  type             = "SecureString"
  description      = "Proxmox API token for ${each.value.user_id}"
  value_wo         = proxmox_virtual_environment_user_token.this[each.key].value
  value_wo_version = var.proxmox_token_rotation_version
}
