#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=wayland-hypr
VER=1.23.1
if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version https://gitlab.freedesktop.org/wayland/wayland.git "")
    if [[ -n "$NEW_VER" ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/wayland-$VER" "$DEPS_DIR/wayland-$VER.tar.xz"
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "wayland-$VER" ]; then
    wget -q --show-progress --timeout=30 "https://gitlab.freedesktop.org/wayland/wayland/-/releases/$VER/downloads/wayland-$VER.tar.xz"
    tar -xf "wayland-$VER.tar.xz"
fi

cd "wayland-$VER"
rm -rf build
meson setup build --prefix=/usr --buildtype=release \
    -Ddocumentation=false -Dtests=false
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "Wayland compositor protocol library (Hyprland build)" "$STAGE" "libffi8"
