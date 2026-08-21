#!/usr/bin/env bash
set -euo pipefail

# Hostinger deployments can restore esbuild without its executable bit.
# Repair it before the build, then explicitly run its native installer.
if [ -d node_modules/.pnpm ]; then
  find node_modules/.pnpm -type f -path '*/esbuild/bin/esbuild' -exec chmod u+x {} +
fi

esbuild_install="$(find node_modules/.pnpm -type f -path '*/esbuild/install.js' -print -quit 2>/dev/null || true)"
if [ -z "$esbuild_install" ]; then
  echo "Could not locate esbuild/install.js" >&2
  exit 1
fi

node "$esbuild_install"