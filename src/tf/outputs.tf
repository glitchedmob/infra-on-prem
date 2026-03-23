output "headscale_proxmox_auth_key_ssm_paths" {
  value = {
    for node_name, parameter in aws_ssm_parameter.headscale_proxmox_auth_key :
    node_name => parameter.name
  }
  description = "SSM parameter paths for per-node Headscale pre-auth keys"
}

output "proxmox_user_token_ssm_paths" {
  value = {
    for token_key, parameter in aws_ssm_parameter.proxmox_user_token :
    token_key => parameter.name
  }
  description = "SSM parameter paths for Proxmox API tokens"
}
