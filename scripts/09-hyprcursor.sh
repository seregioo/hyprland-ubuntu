#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=hyprcursor
VER=0.1.13

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "hyprcursor" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/hyprwm/hyprcursor.git
fi

cd hyprcursor
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" cmake --install build

make_deb "$PKG" "$VER" "Hyprland cursor library" "$STAGE" "hyprlang, libzip-hypr, tomlplusplus-hypr, librsvg2-2"
