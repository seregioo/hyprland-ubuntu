#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building hyprwayland-scanner v0.4.6 ==="
cd "$DEPS_DIR"

VERSION="v0.4.6"
if command -v hyprwayland-scanner &>/dev/null; then
    echo "hyprwayland-scanner already installed"
    exit 0
fi

if [ ! -d "hyprwayland-scanner" ]; then
    git clone --depth 1 --branch "$VERSION" https://github.com/hyprwm/hyprwayland-scanner.git
fi

cd hyprwayland-scanner
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

echo "=== hyprwayland-scanner installed: $(hyprwayland-scanner --version 2>&1 || echo 'done') ==="
