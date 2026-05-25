#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/env.sh"

echo "=== Building hyprland-qtutils v0.1.5 ==="
cd "$DEPS_DIR"

if [ -f "$PREFIX/lib/libhyprland-qtutils.so" ]; then
    echo "hyprland-qtutils already installed"
    exit 0
fi

if [ ! -d "hyprland-qtutils" ]; then
    git clone --depth 1 --branch v0.1.5 https://github.com/hyprwm/hyprland-qtutils.git
fi

cd hyprland-qtutils
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

echo "=== hyprland-qtutils installed ==="
