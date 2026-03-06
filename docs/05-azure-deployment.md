# Azure Deployment

This guide covers deploying to Azure Container Apps from scratch using the Azure CLI.

## Prerequisites

### 1. Azure Subscription
You need an Azure subscription with:
- Contributor access to create resource groups and Container Apps
- Access to register resource providers

### 2. Install Azure CLI
```bash
# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Or via pip
pip install azure-cli
```

### 3. Log in to Azure
```bash
az login

# Set the correct subscription
az account set --subscription "Your Subscription Name"
```

### 4. Register Resource Providers
```bash
az provider register --namespace Microsoft.App --wait
az provider register --namespace Microsoft.OperationalInsights --wait
```

Verify registration:
```bash
az provider show -n Microsoft.App --query registrationState
# Should return "Registered"
```

### 5. Make Container Image Public
The ghcr.io package must be public for Azure to pull it:
1. Go to https://github.com/users/Curio-Data/packages
2. Find `bouncy-ball-connectivity`
3. Settings → Set visibility to **Public**

---

## Option A: Using the Deploy Script

```bash
# Update .env with your values
vim .env

# Run the deploy script
bash scripts/deploy.sh
```

---

## Option B: Manual Deployment (Step by Step)

### Step 1: Set Environment Variables
```bash
# Edit these values as needed
export SUBSCRIPTION="your-subscription-name"
export LOCATION="uksouth"  # or northeurope, eastus, etc.
export RESOURCE_GROUP="rg-connectivity-test"
export ENVIRONMENT="cae-connectivity-test"
export APP_NAME="connectivity-animation-test"
export IMAGE="ghcr.io/curio-data/bouncy-ball-connectivity:latest"
export APP_PORT="3000"
```

### Step 2: Set Subscription
```bash
az account set --subscription "$SUBSCRIPTION"
```

### Step 3: Create Resource Group
```bash
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"
```

**Output:**
```
{
  "id": "/subscriptions/.../resourceGroups/rg-connectivity-test",
  "location": "uksouth",
  "name": "rg-connectivity-test",
  "provisioningState": "Succeeded"
}
```

### Step 4: Create Container Apps Environment
```bash
az containerapp env create \
  --name "$ENVIRONMENT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION"
```

**Output:**
```
{
  "id": "/subscriptions/.../containerAppsEnvironments/cae-connectivity-test",
  "name": "cae-connectivity-test",
  "resourceGroup": "rg-connectivity-test"
}
```

### Step 5: Create Container App
```bash
az containerapp create \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --environment "$ENVIRONMENT" \
  --image "$IMAGE" \
  --target-port "$APP_PORT" \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 1 \
  --cpu 0.25 \
  --memory 0.5Gi
```

**Parameters explained:**
| Parameter | Description |
|-----------|-------------|
| `--image` | Container image to deploy |
| `--target-port` | Port the container listens on |
| `--ingress external` | Makes the app publicly accessible |
| `--min-replicas 1` | Keep at least 1 instance running |
| `--max-replicas 1` | Maximum 1 instance (for cost control) |
| `--cpu 0.25` | 0.25 vCPU |
| `--memory 0.5Gi` | 512 MiB RAM |

### Step 6: Get the Application URL
```bash
az containerapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn \
  -o tsv
```

**Output:**
```
connectivity-animation-test.xxx.uksouth.azurecontainerapps.io
```

### Step 7: Verify Deployment
```bash
curl -s https://connectivity-animation-test.xxx.uksouth.azurecontainerapps.io | head -20
```

---

## Configuration Options

### Scale Settings
```bash
# Scale-to-zero (cold start on first request)
--min-replicas 0 --max-replicas 1

# Always-on (no cold start)
--min-replicas 1 --max-replicas 1

# Auto-scaling
--min-replicas 0 --max-replicas 10
```

### Resource Allocation
```bash
# Small (used in this demo)
--cpu 0.25 --memory 0.5Gi

# Medium
--cpu 0.5 --memory 1Gi

# Large
--cpu 1 --memory 2Gi
```

---

## Check Status

```bash
# View all Container Apps in resource group
az containerapp list --resource-group "$RESOURCE_GROUP" -o table

# View specific app details
az containerapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" -o json

# Check revision
az containerapp revision list --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" -o table
```

---

## Update Deployment

To deploy a new version of the image:

```bash
# Update the container image
az containerapp update \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --image "ghcr.io/curio-data/bouncy-ball-connectivity:latest"
```

---

## Teardown

### Delete only the Container App
```bash
az containerapp delete \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --yes
```

### Delete the entire Resource Group (recommended)
```bash
az group delete \
  --name "$RESOURCE_GROUP" \
  --yes
```

This deletes the resource group and all child resources (Container Apps Environment, Container App, etc.).

---

## Troubleshooting

### Image Pull Failures
```bash
# Check if image is public
podman pull ghcr.io/curio-data/bouncy-ball-connectivity:latest

# Check container app logs
az containerapp logs show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --tail 50
```

### Network Issues
```bash
# Check ingress configuration
az containerapp ingress show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP"
```

### Restart Container
```bash
az containerapp restart --name "$APP_NAME" --resource-group "$RESOURCE_GROUP"
```
