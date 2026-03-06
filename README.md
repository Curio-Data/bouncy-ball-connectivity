# Connectivity Animation Test

A physics-based bouncing ball animation deployed on Azure Container Apps. This project tests the Container Apps deployment path for the PSD Sprint Azure infrastructure.

## Live Demo

**URL**: https://connectivity-animation-test.braveriver-6e4b51e6.uksouth.azurecontainerapps.io

## Features

- **Physics Animation**: Matter.js-powered bouncing ball with perpetual motion
- **Light/Dark Mode**: System preference detection + manual toggle
- **Responsive**: Adapts to any screen size
- **Containerised**: Runs anywhere with Bun runtime

## Tech Stack

| Component | Technology |
|----------|------------|
| Framework | SvelteKit + Svelte 5 |
| Runtime | Bun |
| Physics | Matter.js |
| Container | Docker/Podman |
| Cloud | Azure Container Apps |

## Quick Start

### Prerequisites

- Bun
- Podman (for local testing)
- Azure CLI (for deployment)

### Local Development

```bash
# Install dependencies
bun install

# Run dev server
bun run dev
```

### Build Container

```bash
podman build -t connectivity-animation-test:local .
podman run -d -p 3000:3000 connectivity-animation-test:local
```

### Deploy to Azure

```bash
# Update .env with your settings
vim .env

# Deploy
bash scripts/deploy.sh
```

## Project Structure

```
├── src/
│   ├── lib/
│   │   └── BouncingBall.svelte   # Physics component
│   └── routes/
│       ├── +layout.svelte          # Theme provider
│       └── +page.svelte           # Main page
├── scripts/
│   ├── deploy.sh                   # Azure deployment
│   ├── status.sh                  # Check deployment
│   └── teardown.sh                # Remove resources
├── docs/                          # Documentation
├── Dockerfile                     # Container build
└── .github/workflows/            # CI/CD
```

## Documentation

- [Prerequisites](docs/01-prerequisites.md)
- [Local Development](docs/02-local-development.md)
- [Container Build](docs/03-container-build.md)
- [CI/CD](docs/04-ci-cd.md)
- [Azure Deployment](docs/05-azure-deployment.md)
- [Cost Breakdown](docs/06-cost-breakdown.md)

## CI/CD

The project uses GitHub Actions to build and push the container to ghcr.io on every push to main.

## Azure Configuration

| Setting | Value |
|---------|-------|
| CPU | 0.25 vCPU |
| Memory | 0.5 GiB |
| Min Replicas | 1 |
| Max Replicas | 1 |
| Location | UK South |

## Cost

The app runs on Azure Container Apps consumption plan. See [Cost Breakdown](docs/06-cost-breakdown.md) for details.

## License

MIT
