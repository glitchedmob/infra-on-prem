terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.33"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.106"
    }
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "~> 1.99"
    }
  }
}
