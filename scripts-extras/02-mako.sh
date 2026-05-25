#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/env.sh"

echo "=== Building mako v1.11.0 ==="
cd "$DEPS_DIR"

if command -v "$PREFIX/bin/mako" >/dev/null 2>&1; then
    echo "mako already installed"
    exit 0
fi

if [ ! -d "mako" ]; then
    git clone --depth 1 --branch v1.11.0 https://github.com/emersion/mako.git
fi

cd mako
meson setup build --prefix="$PREFIX" --buildtype=release
ninja -C build
ninja -C build install

echo "=== mako installed ==="
