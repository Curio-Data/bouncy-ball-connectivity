# Azure Deployment

This guide covers deploying to Azure Container Apps.

## Prerequisites

- Azure subscription with Contributor access
- Resource group and Container Apps environment already created
- ghcr.io package set to public

## Deploy

```bash
bash scripts/deploy.sh
```

Or manually:

```bash
source .env
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
  --memory 0.5Gi
```

## Check Status

```bash
bash scripts/status.sh
```

## Verify Deployment

```bash
# Get the FQDN
az containerapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn -o tsv

# Test the endpoint
curl https://<fqdn>
```

## Teardown

```bash
bash scripts/teardown.sh
```

This deletes the resource group and all associated resources.

## Configuration

Edit `.env` to change:
- `RESOURCE_GROUP`: Azure resource group name
- `ENVIRONMENT`: Container Apps environment
- `APP_NAME`: Container app name
- `CONTAINER_IMAGE`: Image to deploy
