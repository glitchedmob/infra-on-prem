# infra-on-prem

Operates LZ on-prem networking and virtualization hosts (MikroTik + Proxmox) with OpenTofu and Ansible automation.

## Scope
- Owns: router/switch config (VLANs, DHCP, DNS, firewall/NAT), Proxmox access resources, and host automation.
- Owns: local OpenTofu state workflow with explicit S3 fetch/backup sync.

## Structure
- `src/tf/`: OpenTofu for MikroTik network config and Proxmox platform resources.
- `src/ansible/`: Playbooks for on-prem host and Proxmox operational tasks.
- `src/scripts/on-prem-state.sh`: Local state fetch/backup sync with S3.

## Credentials

Complete the one-time manual import into AWS SSM before sourcing `.envrc` or running credential-dependent Makefile commands. There is no import playbook or automatic 1Password fallback.

Copy `.envrc.example` and set your AWS profile, endpoints, and state bucket. SSM parameters are stored in `us-east-2`.

Store these parameters as `SecureString` under `/infra/lz/infra-on-prem/`:

| Parameter suffix | Existing credential |
| --- | --- |
| `X86_NODE_01_SSH_PASS` | Node 1 root password |
| `X86_NODE_02_SSH_PASS` | Node 2 root password |
| `X86_NODE_03_SSH_PASS` | Node 3 root password |
| `ssh-private-key` | Shared Proxmox SSH private key, exported in OpenSSH format |
| `ssh-public-key` | Matching shared Proxmox SSH public key |
| `TF_VAR_router_username` | Router API username |
| `TF_VAR_router_password` | Router API password |
| `TF_VAR_switch_username` | Switch API username |
| `TF_VAR_switch_password` | Switch API password |
| `TF_VAR_headscale_api_key` | Headscale API key |

`.envrc` loads the environment credentials from SSM and derives the Proxmox provider password from node 1's password. Ansible reads the SSH key directly from SSM, matching the VM workload repos. It uses an Ansible-managed temporary SSH agent, independent of desktop agents. Private keys are not exported into `.envrc` or written to a persistent local key file.

SSM access requires permission to read the parameters and decrypt them with their KMS key. Node passwords remain necessary for Proxmox API access after password SSH is disabled.

## SSH access paths

One inventory, `src/ansible/inventory.yml`, contains two entries per physical node:

| Key-authenticated name | Installer-password alias | IP |
| --- | --- | --- |
| `x86-node-01` | `x86-node-01-bootstrap` | `10.0.0.3` |
| `x86-node-02` | `x86-node-02-bootstrap` | `10.0.0.4` |
| `x86-node-03` | `x86-node-03-bootstrap` | `10.0.0.5` |

Canonical entries belong to `proxmox_nodes` and their cluster groups. Password aliases belong only to `bootstrap`. YAML anchors share each node's IP and metadata without sharing connection variables. Both entries remain in inventory after setup; a hardened node intentionally rejects its password alias.

Choose the access method by name, with no inventory selector or authentication arguments:

```bash
make ansible-shell HOST=x86-node-03-bootstrap COMMAND='hostname'
make ansible-shell HOST=x86-node-03 COMMAND='hostname'
```

Keep shell queries read-only. Do not target `all`, since it contains both aliases for each machine.

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
- For fresh installations, use the `-bootstrap` alias while password SSH is enabled.
- Coordinate the switch port's VLAN configuration with `configure-network-vlan.yml` before running the network cutover. That playbook expects tagged management VLAN 11; it must not run against an unchanged access port.
- Limit bootstrap playbooks to the intended alias using the existing Makefile `ARGS` support:
  ```bash
  make ansible PLAYBOOK=configure-network-vlan.yml ARGS='--limit x86-node-03-bootstrap'
  make ansible PLAYBOOK=setup-ssh-keys.yml ARGS='--limit x86-node-03-bootstrap'
  ```
- `setup-ssh-keys.yml` adds the SSM public key, verifies a connection through the canonical entry, then disables password SSH. It preserves existing authorized keys.
- After setup, query and manage the node through its canonical name. No inventory promotion or entry removal is needed.
- Run `cluster-join.yml` against canonical cluster entries, never bootstrap aliases. Limit it to a single cluster group.
- Run `tailscale-headscale.yml` after host networking and cluster membership are stable.

## Risk notes
- `configure-network-vlan.yml` rewrites `/etc/network/interfaces` and reboots hosts.
- `storage-vmdata.yml` wipes/repartitions the VM data disk and removes `local-lvm`.

## Operating constraints
- This repo uses local Terraform state with explicit S3 sync, not a remote backend lock flow.
- This repo has no CI apply pipeline and is intended for operator-driven automation with physical access to the hardware.