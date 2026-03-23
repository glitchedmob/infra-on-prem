terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.33"
    }
    headscale = {
      source  = "awlsring/headscale"
      version = "~> 0.5"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.97"
    }
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "~> 1.99"
    }
  }
}
