# Phase 1 — Issues Fixed

## 1. `onMount` never fires in child components (root cause)

In Svelte 5 (v5.53.7) with SvelteKit, `onMount` callbacks silently fail to execute in child components rendered from `+page.svelte`. The layout's `onMount` had the same issue. The compiled output showed the component function executing and the callback being registered, but the lifecycle flush never occurred — no errors, no console output, just silent failure.

**Fix**: Replaced all `onMount` usage with `$effect()` guarded by an `initialized` flag. `$effect` uses a different internal scheduling path and fires correctly.

**Files changed**: `src/lib/BouncingBall.svelte`, `src/routes/+layout.svelte`

## 2. `app.css` not imported

The global stylesheet (`src/app.css`) containing all CSS custom properties for light/dark theming was never imported. The `:root` variables (`--color-bg`, `--color-wall`, etc.) were defined but unreachable — body background was transparent and theme switching had no visual effect.

**Fix**: Added `import '../app.css'` to `+layout.svelte`.

**File changed**: `src/routes/+layout.svelte`

## 3. Ball trapped against top wall

The perpetual motion impulse always pushed upward (`y: -IMPULSE_FORCE`). Over time the ball accumulated upward energy and lodged against the ceiling with near-zero velocity, triggering more upward impulses in a feedback loop.

**Fix**: Changed to random-angle impulses (`Math.cos/sin(randomAngle) * force`) so the ball gets kicked in varied directions and never settles against any single wall.

**File changed**: `src/lib/BouncingBall.svelte`

## 4. Added visible bounce frame

The original design had invisible walls at the viewport edges. The ball bounced but there was no visual feedback showing the boundaries.

**Fix**: Added a centered rectangular frame (max 800x600, with 60px viewport padding) drawn on the canvas each frame using `strokeRect`. Physics walls are positioned to match the frame edges. The frame adapts on resize and uses the `--color-wall` CSS variable for theme-aware colouring.

**File changed**: `src/lib/BouncingBall.svelte`

## 5. High-energy physics tuning

The original physics values (restitution 0.85, gravity 1, no initial velocity) produced low-energy bouncing that settled quickly near the bottom wall.

**Fix**:

| Parameter | Before | After |
|-----------|--------|-------|
| Ball restitution | 0.85 | 1.0 |
| Wall restitution | 0 | 1.0 |
| Gravity | 1.0 | 0.5 |
| Min velocity threshold | 2 | 10 |
| Impulse force | 0.008 | 0.035 |
| Air friction | 0.001 | 0.0005 |
| Initial velocity | none | `{x: 10, y: -15}` |

The ball now bounces off all four walls with sustained high energy.

**File changed**: `src/lib/BouncingBall.svelte`

## Phase 1 Test Gates — All Pass

| Test | Method | Result |
|------|--------|--------|
| Page title is "Connectivity Animation Test" | `page.title()` | PASS |
| Canvas element exists and is visible | `locator('canvas').isVisible()` | PASS |
| Animation is running | Two screenshots 1s apart differ | PASS |
| Dark/light toggle exists and functions | Click toggle, verify `.dark` class toggles | PASS |
| Mobile viewport renders correctly | 375x667, no horizontal overflow | PASS |
