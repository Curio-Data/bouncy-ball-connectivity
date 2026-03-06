# Prerequisites

This document describes the tools required to develop and deploy the Connectivity Animation Test.

## Required Tools

| Tool | Purpose | Version Check |
|------|---------|---------------|
| Bun | Runtime and package manager | `bun --version` |
| Podman | Container build and testing | `podman --version` |
| Azure CLI | Azure resource management | `az --version` |
| GitHub CLI | CI/CD and repository management | `gh --version` |
| Playwright | Browser automation testing | `npx playwright --version` |

## Installation

### Bun
```bash
curl -fsSL https://bun.sh/install | bash
```

### Podman
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install podman
```

### Azure CLI
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### GitHub CLI
```bash
# Ubuntu/Debian
sudo apt-get install gh
```

### Playwright
```bash
npx playwright install --with-deps chromium
```

## Running Preflight

Run the preflight script to verify all tools are installed:

```bash
bash scripts/preflight.sh
```

This will:
- Check all required tools are installed
- Verify Azure authentication
- Auto-populate `.env` file with GitHub and Azure details
