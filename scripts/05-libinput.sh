#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=libinput-hypr
VER=1.28.0
if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version https://gitlab.freedesktop.org/libinput/libinput.git "")
    if [[ -n "$NEW_VER" ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/libinput-$VER" "$DEPS_DIR/libinput-$VER.tar.gz"
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "libinput-$VER" ]; then
    wget -q --show-progress --timeout=30 "https://gitlab.freedesktop.org/libinput/libinput/-/archive/$VER/libinput-$VER.tar.gz"
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

make_deb "$PKG" "$VER" "libinput input device library (Hyprland build)" "$STAGE" "libudev1, libseat1" "libinput10, libinput-bin"
