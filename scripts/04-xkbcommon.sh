#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=libxkbcommon-hypr
VER=1.13.1
if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version https://github.com/xkbcommon/libxkbcommon.git xkbcommon-)
    if [[ -n "$NEW_VER" ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/libxkbcommon-xkbcommon-$VER" "$DEPS_DIR/xkbcommon-$VER.tar.gz"
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
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
