#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/pkg-helper.sh"

# --- hyprpicker ---
PKG=hyprpicker
VER=0.4.7

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "hyprpicker" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/hyprwm/hyprpicker.git
fi

cd hyprpicker
rm -rf build
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" cmake --install build

make_deb "$PKG" "$VER" "Hyprland color picker and screen freeze utility" "$STAGE" "hyprutils"
