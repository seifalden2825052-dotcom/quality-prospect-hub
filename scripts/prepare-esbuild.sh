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

# Replace the inode instead of relying on chmod to mutate a restored symlink
# or a content-store file. Hostinger's deployment filesystem can preserve the
# non-executable mode across a direct chmod.
esbuild_fixed="${esbuild_binary}.hostinger-fixed"
cp "$esbuild_binary" "$esbuild_fixed"
chmod 755 "$esbuild_fixed"
if [ ! -x "$esbuild_fixed" ]; then
  echo "Could not make the esbuild binary executable" >&2
  exit 1
fi
mv -f "$esbuild_fixed" "$esbuild_binary"
chmod 755 "$esbuild_binary"
if [ ! -x "$esbuild_binary" ]; then
  echo "The esbuild binary is still not executable after replacement" >&2
  exit 1
fi

esbuild_install="$(find node_modules/.pnpm -type f -path '*/esbuild/install.js' -print -quit 2>/dev/null || true)"
if [ -z "$esbuild_install" ]; then
  echo "Could not locate esbuild/install.js" >&2
  exit 1
fi

node "$esbuild_install"