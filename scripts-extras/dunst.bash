#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/pkg-helper.sh"

PKG=dunst-hypr
VER=1.13.2

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

sudo apt-get install -y libdbus-1-dev libx11-dev libxinerama-dev \
    libxrandr-dev libxss-dev libglib2.0-dev libpango1.0-dev \
    libgtk-3-dev libxdg-basedir-dev libgdk-pixbuf-2.0-dev \
    libnotify-dev libwayland-dev wayland-protocols

cd "$DEPS_DIR"
if [ ! -d "dunst" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/dunst-project/dunst.git
fi

cd dunst
make PREFIX=/usr WAYLAND=1 X11=1 -j$(nproc)

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
make PREFIX=/usr DESTDIR="$STAGE" install

make_deb "$PKG" "$VER" "Lightweight notification daemon with Wayland ARGB support" "$STAGE" "libcairo2, libpango-1.0-0, libwayland-client0, libgdk-pixbuf-2.0-0, libglib2.0-0t64, libnotify4" "dunst"
