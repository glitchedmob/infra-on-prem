locals {
  proxmox_images = {
    debian13 = {
      file_name          = "debian-13-genericcloud-amd64.qcow2"
      url                = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
      content_type       = "import"
      file_format        = "qcow2"
      checksum           = "df2bd468b08566c0409a7982d6489d73499ad22f9a28646b538c2f21d08f15040a5e4737952ca209e9ad4488cd00793191791be9f135dee93082c86fcca3300c"
      checksum_algorithm = "sha512"
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

resource "proxmox_download_file" "images" {
  for_each = local.proxmox_image_downloads

  node_name          = each.value.node_name
  datastore_id       = each.value.datastore_id
  content_type       = each.value.content_type
  file_name          = each.value.file_name
  url                = each.value.url
  checksum           = each.value.checksum
  checksum_algorithm = each.value.checksum_algorithm
}
