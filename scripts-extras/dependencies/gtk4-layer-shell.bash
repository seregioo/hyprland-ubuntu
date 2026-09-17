#!/bin/bash
set -e
source "$(dirname "$0")/../../scripts/pkg-helper.sh"

# --- gtk4-layer-shell (not packaged for Ubuntu 24.04) ---
GTK4LS_PKG=gtk4-layer-shell
GTK4LS_VER=1.1.0

if pkg-config --atleast-version=1.0.0 gtk4-layer-shell-0 2>/dev/null; then
    echo "$GTK4LS_PKG already available"
    exit 0
fi

echo "=== Building gtk4-layer-shell $GTK4LS_VER ==="

sudo apt-get install -y \
    libgtk-4-dev libwayland-dev \
    gobject-introspection libgirepository1.0-dev \
    valac gtk-doc-tools 2>&1 | tail -5

cd "$DEPS_DIR"
if [ ! -d "gtk4-layer-shell" ]; then
    git clone --depth 1 --branch "v$GTK4LS_VER" https://github.com/wmww/gtk4-layer-shell.git
fi

cd gtk4-layer-shell
rm -rf build
meson setup build --prefix=/usr --buildtype=release -Dtests=false -Dexamples=false -Ddocs=false
ninja -C build

STAGE="$DEPS_DIR/${GTK4LS_PKG}_${GTK4LS_VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$GTK4LS_PKG" "$GTK4LS_VER" "GTK4 library for Wayland Layer Shell protocol" "$STAGE" "libgtk-4-1, libwayland-client0"
