#!/usr/bin/env bash
set -euo pipefail

export ESBUILD_BINARY_PATH="$(bash ./scripts/prepare-esbuild.sh)"

pnpm run typecheck
pnpm --filter @workspace/top-quality-prospect run build
pnpm --filter @workspace/api-server run build