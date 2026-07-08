locals {
  proxmox_images = {
    debian13 = {
      file_name          = "debian-13-genericcloud-amd64.qcow2"
      url                = "https://cloud.debian.org/images/cloud/trixie/20260706-2531/debian-13-genericcloud-amd64-20260706-2531.qcow2"
      content_type       = "import"
      file_format        = "qcow2"
      checksum           = "b565b4414a720b96f5ba0fdd41521138bbfbd53f6c1cf17f9a22088484190d2a0ec24e7fdfb76314710ad4c11c1056b5080883a2e4d40bc27cc353116eecd7e2"
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
