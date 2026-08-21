#!/usr/bin/env bash
set -euo pipefail

# Full build for machines that can run esbuild (Replit, CI, Vercel, local).
# Hostinger itself never runs this: it uses the committed prebuilt output via
# scripts/build-if-needed.mjs.
corepack pnpm run typecheck
corepack pnpm --filter @workspace/top-quality-prospect run build
corepack pnpm --filter @workspace/api-server run build
corepack pnpm --filter @workspace/api-server exec ncc build src/serverless.ts -o dist-serverless -t -m
