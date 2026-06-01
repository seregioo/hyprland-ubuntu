#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=libdisplay-info-hypr
VER=0.2.0
if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version https://gitlab.freedesktop.org/emersion/libdisplay-info.git "")
    if [[ -n "$NEW_VER" ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/libdisplay-info-"*
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "libdisplay-info-$VER" ]; then
    git -c 'http.version=HTTP/1.1' clone --depth 1 --branch "$VER" https://gitlab.freedesktop.org/emersion/libdisplay-info.git "libdisplay-info-$VER" || \
    GIT_SSH_COMMAND="ssh -4" git clone --depth 1 --branch "$VER" https://gitlab.freedesktop.org/emersion/libdisplay-info.git "libdisplay-info-$VER"
fi

cd "libdisplay-info-$VER"
rm -rf build
meson setup build --prefix=/usr --buildtype=release
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "EDID and DisplayID library (Hyprland build)" "$STAGE"
