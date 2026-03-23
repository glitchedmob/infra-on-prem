provider "routeros" {
  alias    = "router"
  hosturl  = var.router_host
  username = var.router_username
  password = var.router_password
}

provider "routeros" {
  alias    = "switch"
  hosturl  = var.switch_host
  username = var.switch_username
  password = var.switch_password
}

provider "aws" {
  region = var.aws_region
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_root_user
  password = var.proxmox_root_password
  insecure = true
}
