#!/usr/bin/env bash
set -euo pipefail

corepack pnpm run typecheck
export ESBUILD_WASM=1
corepack pnpm --filter @workspace/top-quality-prospect exec vite build --config vite.config.ts --configLoader runner
corepack pnpm --filter @workspace/api-server run build