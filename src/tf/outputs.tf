output "proxmox_user_token_ssm_paths" {
  value = {
    for token_key, parameter in aws_ssm_parameter.proxmox_user_token :
    token_key => parameter.name
  }
  description = "SSM parameter paths for Proxmox API tokens"
}

output "proxmox_vm_image_file_ids" {
  description = "Proxmox image file IDs by image name and node"
  value = {
    for image_name in keys(local.proxmox_images) : image_name => {
      for node_name in local.proxmox_nodes :
      node_name => proxmox_virtual_environment_download_file.images["${image_name}:${node_name}"].id
    }
  }
}
