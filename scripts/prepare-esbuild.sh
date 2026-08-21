#!/usr/bin/env bash
set -euo pipefail

# Hostinger's hbuilds source directory can be mounted non-executable. Copy
# esbuild outside that release directory and point all build tools at the copy.
if [ ! -d node_modules/.pnpm ]; then
  echo "node_modules/.pnpm is missing" >&2
  exit 1
fi

source_binary="$(find node_modules/.pnpm -path '*/esbuild/bin/esbuild' -print -quit 2>/dev/null || true)"
if [ -z "$source_binary" ]; then
  echo "Could not locate esbuild/bin/esbuild" >&2
  exit 1
fi

binary_dir="${HOME:-/tmp}/.cache/top-quality-prospect/bin"
mkdir -p "$binary_dir"
binary_path="$binary_dir/esbuild"
cp "$source_binary" "$binary_path"
chmod 755 "$binary_path"

if [ ! -x "$binary_path" ] || ! "$binary_path" --version >/dev/null 2>&1; then
  echo "Could not execute the relocated esbuild binary at $binary_path" >&2
  exit 1
fi

printf '%s\n' "$binary_path"