#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building hyprutils v0.13.1 ==="
cd "$DEPS_DIR"

VERSION="v0.13.1"
if pkg-config --atleast-version=0.13.1 hyprutils 2>/dev/null; then
    echo "hyprutils already satisfied: $(pkg-config --modversion hyprutils)"
    exit 0
fi

if [ ! -d "hyprutils" ]; then
    git clone --depth 1 --branch "$VERSION" https://github.com/hyprwm/hyprutils.git
fi

cd hyprutils
cmake -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

echo "=== hyprutils installed: $(pkg-config --modversion hyprutils) ==="
