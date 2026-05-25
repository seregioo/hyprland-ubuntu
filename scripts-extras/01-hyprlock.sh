#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/env.sh"

echo "=== Building hyprlock v0.9.5 ==="
cd "$DEPS_DIR"

if command -v "$PREFIX/bin/hyprlock" >/dev/null 2>&1; then
    echo "hyprlock already installed"
    exit 0
fi

if [ ! -d "hyprlock" ]; then
    git clone --depth 1 --branch v0.9.5 https://github.com/hyprwm/hyprlock.git
fi

cd hyprlock
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

echo "=== hyprlock installed ==="
