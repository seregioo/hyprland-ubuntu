#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/pkg-helper.sh"

PKG=swaync-hypr
VER=0.10.1

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

echo "=== Building SwayNotificationCenter v$VER ==="

# Build deps
sudo apt-get install -y \
    valac libgtk-3-dev libhandy-1-dev libgranite-dev \
    libgtk-layer-shell-dev libgee-0.8-dev \
    libjson-glib-dev libpulse-dev \
    sassc scdoc 2>&1 | tail -5

cd "$DEPS_DIR"
if [ ! -d "SwayNotificationCenter" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/ErikReider/SwayNotificationCenter.git
else
    # Re-clone if wrong version
    CURRENT_VER=$(git -C SwayNotificationCenter describe --tags 2>/dev/null || echo "unknown")
    if [[ "$CURRENT_VER" != "v$VER" ]]; then
        rm -rf SwayNotificationCenter
        git clone --depth 1 --branch "v$VER" https://github.com/ErikReider/SwayNotificationCenter.git
    fi
fi

cd SwayNotificationCenter
rm -rf build
meson setup build --prefix=/usr --buildtype=release \
    -Dsystemd-service=true \
    -Dman-pages=true
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "Sway/Wayland notification center with GTK panel" "$STAGE" \
    "libgtk-3-0t64, libhandy-1-0, libgranite6, libgtk-layer-shell0, libgee-0.8-2, libjson-glib-1.0-0, libpulse0" \
    "swaync"
