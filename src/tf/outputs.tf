output "proxmox_user_token_ssm_paths" {
  value = {
    for token_key, parameter in aws_ssm_parameter.proxmox_user_token :
    token_key => parameter.name
  }
  description = "SSM parameter paths for Proxmox API tokens"
}
