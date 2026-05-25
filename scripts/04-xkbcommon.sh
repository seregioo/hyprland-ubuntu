#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=libxkbcommon-hypr
VER=1.13.1

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "libxkbcommon-xkbcommon-$VER" ]; then
    wget -q --show-progress "https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-$VER.tar.gz"
    tar -xf "xkbcommon-$VER.tar.gz"
fi

cd "libxkbcommon-xkbcommon-$VER"
rm -rf build
meson setup build --prefix=/usr --buildtype=release \
    -Denable-docs=false -Denable-wayland=true -Denable-x11=true \
    -Denable-bash-completion=false
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "xkbcommon keyboard library (Hyprland build)" "$STAGE"
