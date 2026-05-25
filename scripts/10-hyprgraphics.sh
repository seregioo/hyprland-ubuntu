#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building hyprgraphics v0.5.1 ==="
cd "$DEPS_DIR"

VERSION="v0.5.1"
if pkg-config --atleast-version=0.5.1 hyprgraphics 2>/dev/null; then
    echo "hyprgraphics already satisfied: $(pkg-config --modversion hyprgraphics)"
    exit 0
fi

if [ ! -d "hyprgraphics" ]; then
    git clone --depth 1 --branch "$VERSION" https://github.com/hyprwm/hyprgraphics.git
fi

cd hyprgraphics
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

echo "=== hyprgraphics installed: $(pkg-config --modversion hyprgraphics) ==="
