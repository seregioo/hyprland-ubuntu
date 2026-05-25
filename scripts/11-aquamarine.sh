#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=aquamarine
VER=0.11.0

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "aquamarine" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/hyprwm/aquamarine.git
fi

cd aquamarine
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build --target aquamarine -j$(nproc)

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" cmake --install build

make_deb "$PKG" "$VER" "Aquamarine rendering backend for Hyprland" "$STAGE" "hyprutils, libinput-hypr, libdisplay-info-hypr, libseat1"
