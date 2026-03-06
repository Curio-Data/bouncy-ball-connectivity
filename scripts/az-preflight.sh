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

echo "=== Azure Preflight Checks ==="
echo ""

echo "--- Azure Account ---"
az account show --query "{name:name, id:id, state:state}" -o table

echo ""
echo "--- Resource Providers ---"

check_provider() {
    local provider="$1"
    local state
    state=$(az provider show -n "$provider" --query registrationState -o tsv 2>/dev/null || echo "NotRegistered")
    if [ "$state" = "Registered" ]; then
        echo "[PASS] $provider: Registered"
    else
        echo "[WARN] $provider: $state (attempting to register...)"
        az provider register -n "$provider" --wait
    fi
}

check_provider "Microsoft.App"
check_provider "Microsoft.OperationalInsights"

echo ""
echo "--- User Permissions ---"
az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --query '[].roleDefinitionName' -o table

echo ""
echo "--- Container Apps Quota ---"
az quota list --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.App" --query '[].properties' -o json 2>/dev/null || echo "[INFO] Quota API not available"

echo ""
echo "=== Preflight Complete ==="
