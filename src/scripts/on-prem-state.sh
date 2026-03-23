#!/usr/bin/env bash
set -euo pipefail

# On-prem Terraform state management script
# Handles fetching from and backing up to S3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TF_ON_PREM_DIR="$PROJECT_ROOT/tf"
STATE_KEY="on-prem-networking/terraform.tfstate"

show_usage() {
    echo "Usage: $0 <action> [options]"
    echo ""
    echo "Actions:"
    echo "  fetch    - Fetch state from S3 (downloads to src/tf/terraform.tfstate)"
    echo "  backup   - Backup state to S3 (uploads src/tf/terraform.tfstate)"
    echo ""
    echo "Options:"
    echo "  --allow-missing  Allow fetch to succeed even if no state exists in S3"
    echo ""
    echo "Required environment variables (from .envrc):"
    echo "  INFRA_TF_STATE_BUCKET - S3 bucket name for state storage"
}

fetch_state() {
    local allow_missing=false

    if [[ "${2:-}" == "--allow-missing" ]]; then
        allow_missing=true
    fi

    if [ -z "${INFRA_TF_STATE_BUCKET:-}" ]; then
        echo "Error: INFRA_TF_STATE_BUCKET not set"
        exit 1
    fi

    echo "Fetching on-prem state from S3..."
    echo "  Bucket: $INFRA_TF_STATE_BUCKET"
    echo "  Key: $STATE_KEY"
    echo "  Destination: $TF_ON_PREM_DIR/terraform.tfstate"

    if aws s3 cp "s3://$INFRA_TF_STATE_BUCKET/$STATE_KEY" "$TF_ON_PREM_DIR/terraform.tfstate" 2>/dev/null; then
        echo "Successfully fetched state from S3"
    else
        if [ "$allow_missing" = true ]; then
            echo "Warning: Could not fetch state from S3 (may not exist yet)"
            echo "Continuing with local state..."
        else
            echo "Error: Could not fetch state from S3"
            exit 1
        fi
    fi
}

backup_state() {
    if [ -z "${INFRA_TF_STATE_BUCKET:-}" ]; then
        echo "Error: INFRA_TF_STATE_BUCKET not set"
        exit 1
    fi

    if [ ! -f "$TF_ON_PREM_DIR/terraform.tfstate" ]; then
        echo "Error: No local state file found at $TF_ON_PREM_DIR/terraform.tfstate"
        exit 1
    fi

    echo "Backing up on-prem state to S3..."
    echo "  Source: $TF_ON_PREM_DIR/terraform.tfstate"
    echo "  Bucket: $INFRA_TF_STATE_BUCKET"
    echo "  Key: $STATE_KEY"

    aws s3 cp "$TF_ON_PREM_DIR/terraform.tfstate" "s3://$INFRA_TF_STATE_BUCKET/$STATE_KEY"
    echo "Successfully backed up state to S3"
}

# Main
case "${1:-}" in
    fetch)
        fetch_state "$@"
        ;;
    backup)
        backup_state
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
