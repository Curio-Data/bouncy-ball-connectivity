#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Phase 0: Environment Preflight ==="
echo ""

check_tool() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" &>/dev/null; then
        local version
        version=$($cmd --version 2>/dev/null | head -1 || echo "installed")
        echo "[PASS] $name: $version"
        return 0
    else
        echo "[FAIL] $name: not found"
        return 1
    fi
}

failures=0

echo "--- Tool Checks ---"
check_tool bun "Bun" || ((failures++))
check_tool podman "Podman" || ((failures++))
check_tool az "Azure CLI" || ((failures++))
check_tool gh "GitHub CLI" || ((failures++))

if command -v npx &>/dev/null; then
    if npx playwright --version &>/dev/null; then
        echo "[PASS] Playwright: $(npx playwright --version 2>/dev/null | head -1)"
    else
        echo "[FAIL] Playwright: not available"
        ((failures++))
    fi
else
    echo "[FAIL] npx: not found"
    ((failures++))
fi

if [ -d "$REPO_ROOT/.git" ] && git -C "$REPO_ROOT" rev-parse --git-dir &>/dev/null; then
    echo "[PASS] Git repo: $(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null || echo "found")"
else
    echo "[FAIL] Git repo: not a git repository"
    ((failures++))
fi

if git -C "$REPO_ROOT" remote get-url origin &>/dev/null; then
    echo "[PASS] GitHub remote: configured"
else
    echo "[FAIL] GitHub remote: not configured"
    ((failures++))
fi

echo ""
echo "--- Azure Auth Check ---"
if az account show &>/dev/null; then
    sub_name=$(az account show --query name -o tsv)
    sub_id=$(az account show --query id -o tsv)
    echo "[PASS] Azure: logged in to '$sub_name' ($sub_id)"
else
    echo "[FAIL] Azure: not logged in"
    ((failures++))
fi

if [ $failures -gt 0 ]; then
    echo ""
    echo "ERROR: $failures check(s) failed. Please install missing tools."
    exit 1
fi

echo ""
echo "--- Auto-populating .env ---"

ENV_FILE="$REPO_ROOT/.env"
ENV_EXAMPLE="$REPO_ROOT/.env.example"

if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$ENV_EXAMPLE" ]; then
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        echo "Created .env from .env.example"
    else
        echo "ERROR: .env.example not found"
        exit 1
    fi
else
    echo ".env already exists, preserving values"
fi

GIT_REMOTE=$(git -C "$REPO_ROOT" remote get-url origin)
if [[ "$GIT_REMOTE" =~ github\.com[:/]([^/]+)/([^/]+)\.git$ ]]; then
    GITHUB_OWNER="${BASH_REMATCH[1]}"
    GITHUB_REPO="${BASH_REMATCH[2]}"
    GITHUB_REPO="${GITHUB_REPO%.git}"
elif [[ "$GIT_REMOTE" =~ github\.com/([^/]+)/([^/]+)$ ]]; then
    GITHUB_OWNER="${BASH_REMATCH[1]}"
    GITHUB_REPO="${BASH_REMATCH[2]}"
    GITHUB_REPO="${GITHUB_REPO%.git}"
else
    echo "ERROR: Could not parse GitHub remote: $GIT_REMOTE"
    exit 1
fi

AZURE_SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

sed -i "s|^GITHUB_OWNER=.*|GITHUB_OWNER=$GITHUB_OWNER|" "$ENV_FILE"
sed -i "s|^GITHUB_REPO=.*|GITHUB_REPO=$GITHUB_REPO|" "$ENV_FILE"
sed -i "s|^AZURE_SUBSCRIPTION_NAME=.*|AZURE_SUBSCRIPTION_NAME=$AZURE_SUBSCRIPTION_NAME|" "$ENV_FILE"
sed -i "s|^AZURE_SUBSCRIPTION_ID=.*|AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID|" "$ENV_FILE"

source "$ENV_FILE"
CONTAINER_IMAGE="ghcr.io/${GITHUB_OWNER}/${GITHUB_REPO}:latest"
sed -i "s|^CONTAINER_IMAGE=.*|CONTAINER_IMAGE=$CONTAINER_IMAGE|" "$ENV_FILE"

echo ""
echo "=== Final .env Contents ==="
cat "$ENV_FILE"
echo ""

echo "=== Preflight Complete ==="
echo "Please review the .env contents above and confirm to proceed to Phase 1."
