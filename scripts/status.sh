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

echo "=== Azure Container Apps Status ==="
echo ""

echo "--- Resource Group ---"
az group show --name "$RESOURCE_GROUP" --query "{name:name, location:location, state:provisioningState}" -o table 2>/dev/null || echo "[NOT CREATED]"

echo ""
echo "--- Container Apps Environment ---"
az containerapp env show --name "$ENVIRONMENT" --resource-group "$RESOURCE_GROUP" -o table 2>/dev/null || echo "[NOT CREATED]"

echo ""
echo "--- Container App ---"
az containerapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --query "{name:name, image:properties.template.containers[0].image, status:properties.provisioningState, fqdn:properties.configuration.ingress.fqdn, replicas:properties.replicas}" -o table 2>/dev/null || echo "[NOT CREATED]"

echo ""
echo "--- Cost Estimate ---"
echo "Configuration: 0.25 vCPU, 0.5 GiB memory, scale-to-zero enabled"
echo "Expected cost: ~$0-10/month (free tier: 180K vCPU-s + 360K GiB-s + 2M requests)"
