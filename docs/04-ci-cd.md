# CI/CD

This guide explains the GitHub Actions workflow and how to update the container image.

## Workflow

The `.github/workflows/build-push.yml` workflow:

1. **Trigger**: Runs on push to `main` branch
2. **Build**: Builds the Docker container using the Dockerfile
3. **Push**: Pushes the image to ghcr.io with tags:
   - `latest`
   - `sha-{commit-sha}`

## Making the Package Public

For Azure to pull the image, it must be public:

1. Go to https://github.com/users/Curio-Data/packages
2. Find `bouncy-ball-connectivity`
3. Click Settings → Set visibility to **Public**

## Updating the Image

Simply push to main to trigger a new build:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

## Verifying the Image

```bash
# Log in to ghcr.io
gh auth token | podman login ghcr.io -u your-username --password-stdin

# Pull the latest image
podman pull ghcr.io/curio-data/bouncy-ball-connectivity:latest
```
