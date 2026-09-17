#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/pkg-helper.sh"

PKG=swayosd
VER=0.2.0

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

echo "=== Building SwayOSD v$VER ==="

# Build deps
sudo apt-get install -y \
    libgtk-4-dev libpulse-dev libevdev-dev libudev-dev \
    libinput-dev sassc cargo 2>&1 | tail -5

# gtk4-layer-shell (not in Ubuntu 24.04 repos)
bash "$(dirname "$0")/dependencies/gtk4-layer-shell.bash"

cd "$DEPS_DIR"
if [ ! -d "SwayOSD" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/ErikReider/SwayOSD.git
fi

cd SwayOSD
rm -rf build
meson setup build --prefix=/usr --buildtype=release
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "On-screen display for volume, brightness and Caps Lock on Wayland" "$STAGE" "gtk4-layer-shell, libgtk-4-1, libpulse0, libevdev2, libudev1"
