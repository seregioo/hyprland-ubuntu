#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building hyprlang v0.6.8 ==="
cd "$DEPS_DIR"

VERSION="v0.6.8"
if pkg-config --atleast-version=0.6.7 hyprlang 2>/dev/null; then
    echo "hyprlang already satisfied: $(pkg-config --modversion hyprlang)"
    exit 0
fi

if [ ! -d "hyprlang" ]; then
    git clone --depth 1 --branch "$VERSION" https://github.com/hyprwm/hyprlang.git
fi

cd hyprlang
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

echo "=== hyprlang installed: $(pkg-config --modversion hyprlang) ==="
