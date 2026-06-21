locals {
  proxmox_images = {
    debian13 = {
      file_name          = "debian-13-genericcloud-amd64.qcow2"
      url                = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
      content_type       = "import"
      file_format        = "qcow2"
      checksum           = "35337a6bcd9c6a0f57fdc9a479c0328024cfa1503bb2f4176df541de4eff5c24f285a8aa357f60c8855c35e2f0190f5b7669fdf3a262aa16922acdc0729f17eb"
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
