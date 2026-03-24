.PHONY: help tf-init tf-plan tf-plan-sync tf-show tf-output tf-apply tf-apply-sync tf-validate tf-format tf-lint-fix \
        tf-providers-lock tf-state-fetch tf-state-backup ansible ansible-shell ansible-install ansible-inventory ansible-lint ansible-lint-fix

TF_DIR := src/tf
ANSIBLE_DIR := src/ansible
STATE_SCRIPT := src/scripts/on-prem-state.sh
ENVRC := $(CURDIR)/.envrc
SHELL := bash

help:
	@echo "OpenTofu commands:"
	@echo "  Init:              make tf-init [ARGS='-backend=false']"
	@echo "  Plan:              make tf-plan [ARGS='-out=tfplan -destroy']"
	@echo "  Plan (safe):       make tf-plan-sync [ARGS='-out=tfplan']"
	@echo "  Show:              make tf-show ARGS=<planfile>"
	@echo "  Output:            make tf-output [ARGS='-json']"
	@echo "  Apply:             make tf-apply [ARGS='-auto-approve tfplan']"
	@echo "  Apply (safe):      make tf-apply-sync [ARGS='-auto-approve']"
	@echo "  Validate:          make tf-validate"
	@echo "  Format check:      make tf-format"
	@echo "  Format fix:        make tf-lint-fix"
	@echo "  Providers lock:    make tf-providers-lock"
	@echo ""
	@echo "State commands:"
	@echo "  Fetch from S3:     make tf-state-fetch [ARGS='--allow-missing']"
	@echo "  Backup to S3:      make tf-state-backup"
	@echo ""
	@echo "Ansible commands:"
	@echo "  Install deps:      make ansible-install"
	@echo "  Run playbook:      make ansible PLAYBOOK=playbook.yml [ARGS='-v']"
	@echo "  Inventory:         make ansible-inventory [ARGS='--list']"
	@echo "  Shell command:     make ansible-shell HOST=host COMMAND='cmd' [ARGS='-v']"
	@echo "  Lint:              make ansible-lint"
	@echo "  Lint fix:          make ansible-lint-fix"

tf-init:
	@source "$(ENVRC)" && tofu -chdir=$(TF_DIR) init $(ARGS)

tf-plan:
	@source "$(ENVRC)" && tofu -chdir=$(TF_DIR) plan $(ARGS)

tf-plan-sync: tf-state-fetch
	@$(MAKE) tf-plan ARGS="$(ARGS)"

tf-show:
	@source "$(ENVRC)" && tofu -chdir=$(TF_DIR) show $(ARGS)

tf-output:
	@source "$(ENVRC)" && tofu -chdir=$(TF_DIR) output $(ARGS)

tf-apply:
	@source "$(ENVRC)" && tofu -chdir=$(TF_DIR) apply $(ARGS)

tf-apply-sync: tf-state-fetch
	@$(MAKE) tf-apply ARGS="$(ARGS)"
	@$(MAKE) tf-state-backup

tf-validate:
	@source "$(ENVRC)" && tofu -chdir=$(TF_DIR) validate

tf-format:
	@tofu -chdir=$(TF_DIR) fmt -check -recursive

tf-lint-fix:
	@tofu -chdir=$(TF_DIR) fmt -recursive

tf-providers-lock:
	@source "$(ENVRC)" && cd $(TF_DIR) && tofu providers lock \
		-platform=darwin_amd64 \
		-platform=darwin_arm64 \
		-platform=linux_amd64 \
		-platform=linux_arm64 \
		-platform=windows_amd64 \
		-platform=windows_arm64

tf-state-fetch:
	@source "$(ENVRC)" && bash $(STATE_SCRIPT) fetch $(ARGS)

tf-state-backup:
	@source "$(ENVRC)" && bash $(STATE_SCRIPT) backup

ansible:
	@[ -n "$(PLAYBOOK)" ] || (echo "Error: PLAYBOOK required" && exit 1)
	@source "$(ENVRC)" && cd $(ANSIBLE_DIR) && uv run ansible-playbook playbooks/$(PLAYBOOK) $(ARGS)

ansible-shell:
	@[ -n "$(HOST)" ] || (echo "Error: HOST required (e.g., x86-node-01)" && exit 1)
	@[ -n "$(COMMAND)" ] || (echo "Error: COMMAND required (e.g., 'uname -a')" && exit 1)
	@source "$(ENVRC)" && cd $(ANSIBLE_DIR) && uv run ansible $(HOST) -m shell -a "$(COMMAND)" $(ARGS)

ansible-inventory:
	@source "$(ENVRC)" && cd $(ANSIBLE_DIR) && uv run ansible-inventory $(ARGS)

ansible-install:
	@if [ ! -f "$(ANSIBLE_DIR)/pyproject.toml" ]; then \
		echo "No $(ANSIBLE_DIR)/pyproject.toml found; skipping ansible-install."; \
	else \
		cd $(ANSIBLE_DIR) && uv sync --locked && uv run ansible-galaxy collection install -r requirements.yml; \
	fi

ansible-lint:
	@if [ ! -f "$(ANSIBLE_DIR)/pyproject.toml" ]; then \
		echo "No $(ANSIBLE_DIR)/pyproject.toml found; skipping ansible-lint."; \
	else \
		cd $(ANSIBLE_DIR) && uv run ansible-lint; \
	fi

ansible-lint-fix:
	@if [ ! -f "$(ANSIBLE_DIR)/pyproject.toml" ]; then \
		echo "No $(ANSIBLE_DIR)/pyproject.toml found; skipping ansible-lint-fix."; \
	else \
		cd $(ANSIBLE_DIR) && uv run ansible-lint --fix; \
	fi
