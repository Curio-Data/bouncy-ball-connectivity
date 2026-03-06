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

echo "=== Deploying to Azure Container Apps ==="
echo ""

echo "--- Creating Resource Group ---"
az group create --name "$RESOURCE_GROUP" --location "$AZURE_LOCATION" -o table

echo ""
echo "--- Creating Container Apps Environment ---"
az containerapp env create \
  --name "$ENVIRONMENT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$AZURE_LOCATION" \
  -o table

echo ""
echo "--- Creating Container App ---"
az containerapp create \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --environment "$ENVIRONMENT" \
  --image "$CONTAINER_IMAGE" \
  --target-port "$APP_PORT" \
  --ingress external \
  --min-replicas 0 \
  --max-replicas 1 \
  --cpu 0.25 \
  --memory 0.5Gi \
  -o table

echo ""
echo "--- Retrieving FQDN ---"
FQDN=$(az containerapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --query properties.configuration.ingress.fqdn -o tsv)
echo "Application URL: https://$FQDN"

echo ""
echo "--- Waiting for cold start ---"
sleep 10

echo ""
echo "--- Verifying deployment ---"
for i in {1..6}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$FQDN" 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo "[PASS] HTTP 200 received"
    curl -s "https://$FQDN" | grep -q "Connectivity Animation Test" && echo "[PASS] Title found in response" || echo "[WARN] Title not found in response"
    break
  fi
  echo "Attempt $i: HTTP $STATUS — waiting 15s..."
  sleep 15
done

echo ""
echo "=== Deployment Complete ==="
echo "URL: https://$FQDN"
