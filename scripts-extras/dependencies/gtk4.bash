#!/bin/bash
set -e
source "$(dirname "$0")/../../scripts/pkg-helper.sh"

# --- GTK4 (Ubuntu 24.04 ships 4.14.5, SwayNC 0.12.x needs >= 4.16.13) ---
PKG=gtk4-hypr
VER=4.16.13
REPO=https://gitlab.gnome.org/GNOME/gtk.git

if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version "$REPO" "4.16.")
    if [[ -n "$NEW_VER" ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/gtk4-src"
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

echo "=== Building GTK4 $VER ==="

sudo apt-get install -y \
    libglib2.0-dev libcairo2-dev libpango1.0-dev libgdk-pixbuf-2.0-dev \
    libgraphene-1.0-dev libepoxy-dev libfribidi-dev libharfbuzz-dev \
    libwayland-dev wayland-protocols libxkbcommon-dev \
    libvulkan-dev libegl-dev libgles2-mesa-dev \
    libxrandr-dev libxi-dev libxext-dev libx11-dev libxrender-dev \
    libxcursor-dev libxdamage-dev libxfixes-dev libxinerama-dev \
    libfontconfig-dev libjpeg-dev libpng-dev libtiff-dev \
    libcups2-dev libcolord-dev \
    gobject-introspection libgirepository1.0-dev \
    sassc python3-docutils \
    libcloudproviders-dev glslc 2>&1 | tail -5

cd "$DEPS_DIR"
if [ ! -d "gtk4-src" ]; then
    git clone --depth 1 --branch "$VER" "$REPO" gtk4-src
fi

cd gtk4-src
rm -rf build
meson setup build --prefix=/usr --buildtype=release \
    -Dx11-backend=false \
    -Dwayland-backend=true \
    -Dbroadway-backend=false \
    -Dmedia-gstreamer=disabled \
    -Dprint-cups=disabled \
    -Dvulkan=enabled \
    -Dcloudproviders=disabled \
    -Dtracker=disabled \
    -Dcolord=disabled \
    -Dintrospection=enabled \
    -Ddocumentation=false \
    -Dman-pages=false \
    -Dbuild-demos=false \
    -Dbuild-testsuite=false \
    -Dbuild-examples=false \
    -Dbuild-tests=false
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "GTK4 toolkit (Wayland, built from source for Hyprland extras)" "$STAGE" \
    "libglib2.0-0t64, libcairo2, libpango-1.0-0, libgdk-pixbuf-2.0-0, libgraphene-1.0-0, libepoxy0, libwayland-client0, libvulkan1, libxkbcommon0"
