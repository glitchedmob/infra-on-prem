# infra-on-prem

OpenTofu and Ansible project for glitchedmob on-prem infrastructure migration.

## Migration Model

This repository is migrated in two phases:

1. Phase 2A: RouterOS-only Terraform migration from `infra-old/src/on-prem-networking`.
2. Phase 2B: Layer Proxmox + Headscale + AWS resources and merge Ansible projects.

The Terraform S3 state key stays on `on-prem-networking/terraform.tfstate` for now.

## Structure

- `src/tf/` - RouterOS Terraform stack (Phase 2A base)
- `src/scripts/on-prem-state.sh` - S3 state fetch/backup helper
- `src/ansible/` - Reserved for merged Ansible management/bootstrap content

## Local-First Operations

This project is operated locally. CI is limited to Terraform validate and Ansible lint.

Common commands:

```bash
make tf-state-fetch
make tf-init
make tf-validate
make tf-plan
make tf-state-backup
```

## Required Environment

- `INFRA_TF_STATE_BUCKET` for state fetch/backup script
- `TF_VAR_router_host`, `TF_VAR_router_username`, `TF_VAR_router_password`
- `TF_VAR_switch_host`, `TF_VAR_switch_username`, `TF_VAR_switch_password`
