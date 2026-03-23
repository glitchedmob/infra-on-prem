.PHONY: help tf-init tf-plan tf-show tf-output tf-apply tf-validate tf-format tf-lint-fix \
        tf-state-fetch tf-state-backup ansible-install ansible-lint

TF_DIR := src/tf
ANSIBLE_DIR := src/ansible
STATE_SCRIPT := src/scripts/on-prem-state.sh
SHELL := bash

help:
	@echo "OpenTofu commands:"
	@echo "  Init:              make tf-init [ARGS='-backend=false']"
	@echo "  Plan:              make tf-plan [ARGS='-out=tfplan -destroy']"
	@echo "  Show:              make tf-show ARGS=<planfile>"
	@echo "  Output:            make tf-output [ARGS='-json']"
	@echo "  Apply:             make tf-apply [ARGS='-auto-approve tfplan']"
	@echo "  Validate:          make tf-validate"
	@echo "  Format check:      make tf-format"
	@echo "  Format fix:        make tf-lint-fix"
	@echo ""
	@echo "State commands:"
	@echo "  Fetch from S3:     make tf-state-fetch [ARGS='--allow-missing']"
	@echo "  Backup to S3:      make tf-state-backup"
	@echo ""
	@echo "Ansible commands:"
	@echo "  Install deps:      make ansible-install"
	@echo "  Lint:              make ansible-lint"

tf-init:
	@source .envrc 2>/dev/null || true && tofu -chdir=$(TF_DIR) init $(ARGS)

tf-plan:
	@source .envrc 2>/dev/null || true && tofu -chdir=$(TF_DIR) plan $(ARGS)

tf-show:
	@source .envrc 2>/dev/null || true && tofu -chdir=$(TF_DIR) show $(ARGS)

tf-output:
	@source .envrc 2>/dev/null || true && tofu -chdir=$(TF_DIR) output $(ARGS)

tf-apply:
	@source .envrc 2>/dev/null || true && tofu -chdir=$(TF_DIR) apply $(ARGS)

tf-validate:
	@source .envrc 2>/dev/null || true && tofu -chdir=$(TF_DIR) validate

tf-format:
	@tofu -chdir=$(TF_DIR) fmt -check -recursive

tf-lint-fix:
	@tofu -chdir=$(TF_DIR) fmt -recursive

tf-state-fetch:
	@source .envrc 2>/dev/null || true && bash $(STATE_SCRIPT) fetch $(ARGS)

tf-state-backup:
	@source .envrc 2>/dev/null || true && bash $(STATE_SCRIPT) backup

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
