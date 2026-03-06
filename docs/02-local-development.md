# Local Development

This guide covers how to run the Connectivity Animation Test locally.

## Clone and Install

```bash
git clone https://github.com/Curio-Data/bouncy-ball-connectivity.git
cd bouncy-ball-connectivity
bun install
```

## Run Development Server

```bash
bun run dev
```

The app will be available at http://localhost:5173

## Run Tests

```bash
# Start dev server first
bun run dev &

# Run Playwright tests
cd .agents/skills/playwright-skill
node run.js /tmp/playwright-test-phase1.js
```

## Expected Output

- Page title: "Connectivity Animation Test"
- Canvas with bouncing ball animation
- Theme toggle button (top-right)
- Light/dark mode support
