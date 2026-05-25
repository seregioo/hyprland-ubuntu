#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building aquamarine v0.11.0 ==="
cd "$DEPS_DIR"

VERSION="v0.11.0"
if pkg-config --atleast-version=0.9.3 aquamarine 2>/dev/null; then
    echo "aquamarine already satisfied: $(pkg-config --modversion aquamarine)"
    exit 0
fi

if [ ! -d "aquamarine" ]; then
    git clone --depth 1 --branch "$VERSION" https://github.com/hyprwm/aquamarine.git
fi

cd aquamarine
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build --target aquamarine -j$(nproc)
cmake --install build

echo "=== aquamarine installed: $(pkg-config --modversion aquamarine) ==="
