#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=libinput-hypr
VER=1.28.0

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "libinput-$VER" ]; then
    wget -q --show-progress "https://gitlab.freedesktop.org/libinput/libinput/-/archive/$VER/libinput-$VER.tar.gz"
    tar -xf "libinput-$VER.tar.gz"
fi

cd "libinput-$VER"
rm -rf build
meson setup build --prefix=/usr --buildtype=release \
    -Ddocumentation=false -Dtests=false -Ddebug-gui=false
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "libinput input device library (Hyprland build)" "$STAGE" "libudev1, libseat1"
