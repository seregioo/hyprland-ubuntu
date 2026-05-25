#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building hyprcursor v0.1.13 ==="
cd "$DEPS_DIR"

VERSION="v0.1.13"
if pkg-config --atleast-version=0.1.7 hyprcursor 2>/dev/null; then
    echo "hyprcursor already satisfied: $(pkg-config --modversion hyprcursor)"
    exit 0
fi

if [ ! -d "hyprcursor" ]; then
    git clone --depth 1 --branch "$VERSION" https://github.com/hyprwm/hyprcursor.git
fi

cd hyprcursor
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

echo "=== hyprcursor installed: $(pkg-config --modversion hyprcursor) ==="
