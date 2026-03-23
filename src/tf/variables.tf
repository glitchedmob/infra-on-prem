variable "router_host" {
  description = "MikroTik Router IP or hostname (e.g., 172.20.20.10)"
  type        = string
}

variable "router_username" {
  description = "MikroTik Router API username"
  type        = string
}

variable "router_password" {
  description = "MikroTik Router API password"
  type        = string
  sensitive   = true
}

variable "switch_host" {
  description = "MikroTik Switch IP or hostname (e.g., 172.20.20.11)"
  type        = string
}

variable "switch_username" {
  description = "MikroTik Switch API username"
  type        = string
  default     = "admin"
}

variable "switch_password" {
  description = "MikroTik Switch API password"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for SSM parameters"
  type        = string
  default     = "us-east-2"
}

variable "headscale_host" {
  description = "Headscale hostname"
  type        = string
  default     = "headscale.levizitting.com"
}

variable "headscale_api_key" {
  description = "Headscale API key"
  type        = string
  sensitive   = true
}

variable "headscale_key_rotation_version" {
  description = "Rotation version for Headscale pre-auth keys"
  type        = number
  default     = 4
}

variable "headscale_proxmox_nodes" {
  description = "Proxmox node names that receive Headscale pre-auth keys"
  type        = list(string)
  default     = ["x86-node-01", "x86-node-02"]
}

variable "headscale_proxmox_tag" {
  description = "Headscale ACL tag for Proxmox nodes"
  type        = string
  default     = "tag:proxmox-x86"
}

variable "ssm_path_prefix" {
  description = "SSM parameter path prefix for Headscale auth keys"
  type        = string
  default     = "/homelab/proxmox-node-management"
}

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint (omit /api2/json)"
  type        = string
}

variable "proxmox_root_user" {
  description = "Proxmox root username with realm (e.g. root@pam)"
  type        = string
}

variable "proxmox_root_password" {
  description = "Proxmox root password"
  type        = string
  sensitive   = true
}

variable "proxmox_token_rotation_version" {
  description = "Rotation version for Proxmox API token secrets in SSM"
  type        = number
  default     = 1
}
