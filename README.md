# infra-on-prem

Operates LZ on-prem networking and virtualization hosts (MikroTik + Proxmox) with OpenTofu and Ansible automation.

## Scope
- Owns: router/switch config (VLANs, DHCP, DNS, firewall/NAT), Proxmox access resources, and host automation.
- Owns: local OpenTofu state workflow with explicit S3 fetch/backup sync.

## Structure
- `src/tf/`: OpenTofu for MikroTik network config and Proxmox platform resources.
- `src/ansible/`: Playbooks for on-prem host and Proxmox operational tasks.
- `src/scripts/on-prem-state.sh`: Local state fetch/backup sync with S3.

## Run
```bash
make help
make tf-init
make tf-state-fetch ARGS='--allow-missing'
make tf-plan-sync
make tf-apply-sync
make ansible-install
make ansible PLAYBOOK=cluster-join.yml
make ansible PLAYBOOK=tailscale-headscale.yml
make ansible PLAYBOOK=proxmox-snippets.yml
```

## Operational order
- Use `tf-plan-sync` and `tf-apply-sync` for normal Terraform changes so state is fetched from and backed up to S3.
- Run `configure-network-vlan.yml` before cluster bootstrap tasks on fresh hosts.
- Run `cluster-join.yml` per cluster group (do not mix x86 and arm cluster hosts in one run).
- Run `tailscale-headscale.yml` after host networking and cluster membership are stable.

## Risk notes
- `configure-network-vlan.yml` rewrites `/etc/network/interfaces` and reboots hosts.
- `storage-vmdata.yml` wipes/repartitions the VM data disk and removes `local-lvm`.

## Operating constraints
- This repo uses local Terraform state with explicit S3 sync, not a remote backend lock flow.
- This repo has no CI apply pipeline and is intended for manual operation with physical access to the hardware.
