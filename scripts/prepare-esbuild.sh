#!/usr/bin/env bash
set -euo pipefail

# Hostinger deployments can restore esbuild without its executable bit.
# Repair it before the build, then explicitly run its native installer.
if [ ! -d node_modules/.pnpm ]; then
  echo "node_modules/.pnpm is missing" >&2
  exit 1
fi

esbuild_binary="$(find node_modules/.pnpm -path '*/esbuild/bin/esbuild' -print -quit 2>/dev/null || true)"
if [ -z "$esbuild_binary" ]; then
  echo "Could not locate esbuild/bin/esbuild" >&2
  exit 1
fi

# Do not filter by file type: Hostinger may restore this path as a symlink.
chmod 755 "$esbuild_binary"

esbuild_install="$(find node_modules/.pnpm -type f -path '*/esbuild/install.js' -print -quit 2>/dev/null || true)"
if [ -z "$esbuild_install" ]; then
  echo "Could not locate esbuild/install.js" >&2
  exit 1
fi

node "$esbuild_install"