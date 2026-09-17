#!/bin/bash
set -e
source "$(dirname "$0")/../../scripts/pkg-helper.sh"

# --- granite-7 (Ubuntu 24.04 ships 7.4.0, SwayNC 0.12.x needs >= 7.5.0) ---
PKG=granite-7-hypr
VER=7.5.0
REPO=https://github.com/elementary/granite.git

if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version "$REPO" "")
    # Only pick 7.x versions
    if [[ -n "$NEW_VER" && "$NEW_VER" == 7.* ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/granite-src"
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

echo "=== Building granite-7 $VER ==="

# Requires our custom GTK4 to be installed first
if ! pkg-config --atleast-version=4.16.0 gtk4 2>/dev/null; then
    echo "ERROR: GTK4 >= 4.16 required. Run gtk4.bash first."
    exit 1
fi

sudo apt-get install -y \
    valac libgee-0.8-dev \
    gobject-introspection libgirepository1.0-dev \
    sassc 2>&1 | tail -5

cd "$DEPS_DIR"
if [ ! -d "granite-src" ]; then
    git clone --depth 1 --branch "$VER" "$REPO" granite-src
fi

cd granite-src
rm -rf build
meson setup build --prefix=/usr --buildtype=release
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "Granite-7 GTK4 widget library (built from source for Hyprland extras)" "$STAGE" \
    "gtk4-hypr, libgee-0.8-2, libglib2.0-0t64"
