#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -f "$REPO_ROOT/.env" ]; then
  echo "ERROR: .env not found. Run scripts/preflight.sh first."
  exit 1
fi

set -a
source "$REPO_ROOT/.env"
set +a

echo "=== Azure Teardown ==="
echo ""
echo "WARNING: This will delete all resources in $RESOURCE_GROUP."
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo "--- Deleting Resource Group ---"
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo ""
echo "=== Deletion initiated ==="
echo "Resource group '$RESOURCE_GROUP' is being deleted in the background."
