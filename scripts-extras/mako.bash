#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/pkg-helper.sh"

PKG=mako-notif
VER=1.11.0

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "mako" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/emersion/mako.git
fi

cd mako
meson setup build --prefix=/usr --buildtype=release
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "Lightweight Wayland notification daemon" "$STAGE" "libcairo2, libpango-1.0-0, libwayland-client0"
