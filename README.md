# infra-on-prem

OpenTofu and Ansible project for glitchedmob on-prem infrastructure migration.

## Migration Model

This repository is migrated in two phases:

1. Phase 2A: RouterOS-only Terraform migration from `infra-old/src/on-prem-networking`.
2. Phase 2B: Layer Proxmox + Headscale + AWS resources and merge Ansible projects.

The Terraform S3 state key is `infra-on-prem/terraform.tfstate`.

## Structure

- `src/tf/` - RouterOS Terraform stack (Phase 2A base)
- `src/scripts/on-prem-state.sh` - S3 state fetch/backup helper
- `src/ansible/` - Reserved for merged Ansible management/bootstrap content

## Local-First Operations

This project is operated locally. CI is limited to Terraform validate and Ansible lint.

State management remains local state file + S3 sync script for this project (no S3 backend + DynamoDB locking).

Common commands:

```bash
make tf-init
make tf-validate
make tf-plan-sync ARGS='-out=tfplan'
make tf-apply-sync ARGS='tfplan'
```

Manual state sync commands:

```bash
make tf-state-fetch
make tf-state-backup
```

## Required Environment

- `INFRA_TF_STATE_BUCKET` for state fetch/backup script
- `TF_VAR_router_host`, `TF_VAR_router_username`, `TF_VAR_router_password`
- `TF_VAR_switch_host`, `TF_VAR_switch_username`, `TF_VAR_switch_password`
