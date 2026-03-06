# Container Build

This guide covers building and testing the Docker container locally.

## Build the Container

```bash
podman build -t connectivity-animation-test:local -f Dockerfile .
```

## Run the Container

```bash
podman run -d --name cat-test -p 3000:3000 connectivity-animation-test:local
```

The app will be available at http://localhost:3000

## Run Tests Against Container

```bash
cd .agents/skills/playwright-skill
node run.js /tmp/playwright-test-container.js
```

## Clean Up

```bash
podman stop cat-test && podman rm cat-test
```

## Dockerfile Explanation

The Dockerfile uses a multi-stage build:

1. **Builder stage** (`oven/bun:latest`)
   - Copies package.json and bun.lock
   - Runs `bun install`
   - Copies source code
   - Runs `bun run build`

2. **Runtime stage** (`oven/bun:slim`)
   - Copies build output from builder
   - Exposes port 3000
   - Runs the Bun server
