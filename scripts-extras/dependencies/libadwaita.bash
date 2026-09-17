#!/bin/bash
set -e
source "$(dirname "$0")/../../scripts/pkg-helper.sh"

# --- libadwaita (Ubuntu 24.04 ships 1.5.0, SwayNC 0.12.x needs >= 1.6.1) ---
PKG=libadwaita-hypr
VER=1.6.4
REPO=https://gitlab.gnome.org/GNOME/libadwaita.git

if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version "$REPO" "1.6.")
    if [[ -n "$NEW_VER" ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/libadwaita-src"
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

echo "=== Building libadwaita $VER ==="

# Requires our custom GTK4 to be installed first
if ! pkg-config --atleast-version=4.16.0 gtk4 2>/dev/null; then
    echo "ERROR: GTK4 >= 4.16 required. Run gtk4.bash first."
    exit 1
fi

sudo apt-get install -y \
    libappstream-dev libfribidi-dev \
    gobject-introspection libgirepository1.0-dev \
    valac sassc 2>&1 | tail -5

cd "$DEPS_DIR"
if [ ! -d "libadwaita-src" ]; then
    git clone --depth 1 --branch "$VER" "$REPO" libadwaita-src
fi

cd libadwaita-src
rm -rf build
meson setup build --prefix=/usr --buildtype=release \
    -Dintrospection=enabled \
    -Dvapi=true \
    -Dgtk_doc=false \
    -Dtests=false \
    -Dexamples=false
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "GTK4 Adwaita widget library (built from source for Hyprland extras)" "$STAGE" \
    "gtk4-hypr, libglib2.0-0t64, libappstream5"
