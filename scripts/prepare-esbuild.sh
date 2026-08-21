#!/usr/bin/env bash
set -euo pipefail

# Hostinger deployments can restore esbuild without its executable bit.
# Repair it before the build, then explicitly run its native postinstall.
if [ -d node_modules/.pnpm ]; then
  find node_modules/.pnpm -type f -path '*/esbuild/bin/esbuild' -exec chmod u+x {} +
fi

corepack pnpm rebuild esbuild