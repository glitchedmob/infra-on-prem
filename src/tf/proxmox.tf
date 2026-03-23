locals {
  proxmox_nodes = [
    "x86-node-01",
    "x86-node-02",
  ]

  proxmox_image_datastore_ids = {
    for node_name in local.proxmox_nodes : node_name => "local"
  }

  pool_privileges = [
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit",
    "Pool.Allocate",
    "Pool.Audit",
    "Sys.Audit",
    "VM.Allocate",
    "VM.Audit",
    "VM.Clone",
    "VM.Config.CDROM",
    "VM.Config.Cloudinit",
    "VM.Config.CPU",
    "VM.Config.Disk",
    "VM.Config.HWType",
    "VM.Config.Memory",
    "VM.Config.Network",
    "VM.Config.Options",
    "VM.GuestAgent.Audit",
    "VM.Migrate",
    "VM.PowerMgmt",
  ]

  network_use_privileges = [
    "SDN.Use",
  ]

  datastore_use_privileges = [
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit",
  ]

  pools = {
    sgfdevs = {
      comment            = "managedBy=terraform,team=sgfdevs"
      role_id            = "SgfdevsVmAdmin"
      network_role_id    = "SgfdevsNetworkUse"
      storage_role_id    = "SgfdevsDatastoreUse"
      role_privileges    = local.pool_privileges
      storage_privileges = local.datastore_use_privileges
      allowed_sdn_networks = [
        "sgfdevs",
      ]
      allowed_datastores = [
        "vmdata",
        "local",
      ]
      users = [
        {
          user_id               = "sgfdevs-gha@pve"
          user_comment          = "managedBy=terraform,pool=sgfdevs,purpose=gha"
          token_name            = "gha"
          token_comment         = "managedBy=terraform,pool=sgfdevs,purpose=gha"
          token_ssm_path        = "/homelab/proxmox/sgfdevs/gha-token"
          privileges_separation = false
        },
      ]
    }
  }

  proxmox_pools = { for pool_id, pool in local.pools : pool_id => { comment = pool.comment } }

  sdn_acl_paths = {
    for network_key, network in local.sdn_networks : network_key => "/sdn/zones/${network.zone_id}/${network.vnet_id}"
  }

  datastore_ids = toset(flatten([
    for pool in values(local.pools) : try(pool.allowed_datastores, [])
  ]))

  datastore_acl_paths = {
    for datastore_id in local.datastore_ids :
    datastore_id => "/storage/${datastore_id}"
  }

  proxmox_pool_roles = {
    for pool_id, pool in local.pools : pool.role_id => {
      privileges = pool.role_privileges
    }
  }

  proxmox_network_roles = {
    for pool_id, pool in local.pools : pool.network_role_id => {
      privileges = local.network_use_privileges
    }
    if try(length(pool.allowed_sdn_networks), 0) > 0
  }

  proxmox_storage_roles = {
    for pool_id, pool in local.pools : pool.storage_role_id => {
      privileges = pool.storage_privileges
    }
    if try(length(pool.allowed_datastores), 0) > 0
  }

  proxmox_roles = merge(local.proxmox_pool_roles, local.proxmox_network_roles, local.proxmox_storage_roles)

  pool_users = flatten([
    for pool_id, pool in local.pools : [
      for user in pool.users : merge(user, {
        pool_id              = pool_id
        role_id              = pool.role_id
        network_role_id      = pool.network_role_id
        storage_role_id      = pool.storage_role_id
        allowed_sdn_networks = try(pool.allowed_sdn_networks, [])
        allowed_datastores   = try(pool.allowed_datastores, [])
      })
    ]
  ])

  proxmox_users = {
    for user in local.pool_users : user.user_id => {
      comment = user.user_comment
    }
  }

  proxmox_user_tokens = {
    for user in local.pool_users : "${user.pool_id}_${user.user_id}_${user.token_name}" => {
      user_id               = user.user_id
      token_name            = user.token_name
      comment               = user.token_comment
      ssm_path              = coalesce(try(user.token_ssm_path, ""), "")
      privileges_separation = try(user.privileges_separation, true)
    }
    if try(user.token_name, "") != ""
  }

  proxmox_user_acls = {
    for user in local.pool_users : user.user_id => concat(
      [
        {
          path      = "/pool/${user.pool_id}"
          role_id   = user.role_id
          propagate = true
        }
      ],
      [
        for network_key in user.allowed_sdn_networks : {
          path      = local.sdn_acl_paths[network_key]
          role_id   = user.network_role_id
          propagate = true
        }
        if contains(keys(local.sdn_acl_paths), network_key)
      ],
      [
        for datastore_id in user.allowed_datastores : {
          path      = local.datastore_acl_paths[datastore_id]
          role_id   = user.storage_role_id
          propagate = true
        }
        if contains(keys(local.datastore_acl_paths), datastore_id)
      ]
    )
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
  privileges_separation = each.value.privileges_separation

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
