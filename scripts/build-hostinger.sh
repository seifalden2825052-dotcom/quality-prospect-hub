#!/usr/bin/env bash
set -euo pipefail

export ESBUILD_BINARY_PATH="$(bash ./scripts/prepare-esbuild.sh)"

corepack pnpm run typecheck
corepack pnpm --filter @workspace/top-quality-prospect run build
corepack pnpm --filter @workspace/api-server run build