# infra-on-prem

OpenTofu and Ansible infrastructure for on-prem networking and platform access.

## Scope

- **OpenTofu (`src/tf/`)**: manages RouterOS router/switch config (bridges, interfaces, VLANs, DHCP, DNS, firewall/NAT) and Proxmox access resources.
- **State sync (`src/scripts/on-prem-state.sh`)**: fetches and backs up local Terraform state to S3.
- **Ansible (`src/ansible/`)**: on-prem automation tooling and lint/install workflow.

## Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.11
- [uv](https://docs.astral.sh/uv/) for Ansible tooling
- Required environment variables:
  - `INFRA_TF_STATE_BUCKET`
  - `TF_VAR_router_host`, `TF_VAR_router_username`, `TF_VAR_router_password`
  - `TF_VAR_switch_host`, `TF_VAR_switch_username`, `TF_VAR_switch_password`

## Usage

### OpenTofu

```bash
make tf-init
make tf-plan
make tf-plan-sync ARGS='-out=tfplan'
make tf-show ARGS=tfplan
make tf-output
make tf-apply-sync ARGS='tfplan'
make tf-validate
make tf-format
make tf-lint-fix
make tf-provider-lock ARGS='-platform=darwin_arm64'
```

### State Sync

```bash
make tf-state-fetch
make tf-state-backup
```

### Ansible

```bash
make ansible-install
make ansible-lint
make ansible PLAYBOOK=proxmox-snippets.yml
```

`proxmox-snippets.yml` copies all files in `src/ansible/playbooks/snippets/` to `/var/lib/vz/snippets` on every host in `proxmox_nodes`.

## Operational Notes

- This stack is operated locally.
- CI runs validation/lint checks only.
- State is local plus explicit S3 sync; this stack does not use a remote backend lock flow.
