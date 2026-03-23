locals {
  proxmox_images = {
    debian13 = {
      file_name    = "debian-13-generic-amd64.img"
      url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
      content_type = "iso"
      file_format  = "qcow2"
    }
  }

  proxmox_image_downloads = merge([
    for image_name, image in local.proxmox_images : {
      for node_name in local.proxmox_nodes :
      "${image_name}:${node_name}" => merge(image, {
        image_name   = image_name
        node_name    = node_name
        datastore_id = local.proxmox_image_datastore_ids[node_name]
      })
    }
  ]...)
}

resource "proxmox_virtual_environment_download_file" "images" {
  for_each = local.proxmox_image_downloads

  node_name    = each.value.node_name
  datastore_id = each.value.datastore_id
  content_type = each.value.content_type
  file_name    = each.value.file_name
  url          = each.value.url
}
