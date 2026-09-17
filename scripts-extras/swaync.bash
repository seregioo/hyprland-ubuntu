#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/pkg-helper.sh"

PKG=swaync-hypr
VER=0.12.6
REPO=https://github.com/ErikReider/SwayNotificationCenter.git

if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version "$REPO" "v")
    if [[ -n "$NEW_VER" ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/SwayNotificationCenter"
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

echo "=== Building SwayNotificationCenter v$VER ==="

# --- Build dependencies from source (order matters) ---
DEPS_SCRIPTS="$(dirname "$0")/dependencies"

echo ">>> [swaync] Phase 1: GTK4 from source"
bash "$DEPS_SCRIPTS/gtk4.bash"

echo ">>> [swaync] Phase 2: libadwaita from source"
bash "$DEPS_SCRIPTS/libadwaita.bash"

echo ">>> [swaync] Phase 3: granite-7 from source"
bash "$DEPS_SCRIPTS/granite7.bash"

echo ">>> [swaync] Phase 4: gtk4-layer-shell from source"
bash "$DEPS_SCRIPTS/gtk4-layer-shell.bash"

# --- System build deps ---
sudo apt-get install -y \
    valac libgee-0.8-dev libjson-glib-dev \
    libpulse-dev libwayland-dev \
    gobject-introspection libgirepository1.0-dev \
    sassc scdoc blueprint-compiler 2>&1 | tail -5

# --- SwayNC ---
cd "$DEPS_DIR"
if [ -d "SwayNotificationCenter" ]; then
    # Re-clone if wrong version
    EXISTING_VER=$(git -C SwayNotificationCenter describe --tags 2>/dev/null || echo "unknown")
    if [[ "$EXISTING_VER" != "v$VER" ]]; then
        echo "SwayNotificationCenter: found $EXISTING_VER, need v$VER — re-cloning"
        rm -rf SwayNotificationCenter
    fi
fi
if [ ! -d "SwayNotificationCenter" ]; then
    git clone --depth 1 --branch "v$VER" "$REPO"
fi

cd SwayNotificationCenter
rm -rf build

# Patch for Ubuntu 24.04: valac 0.56 / GLib 2.80 compat
# RegexCompileFlags.DEFAULT doesn't exist in GLib < 2.84 vapi
sed -i 's/RegexCompileFlags\.DEFAULT/(RegexCompileFlags) 0/g' src/controlCenter/widgets/mpris/mpris.vala
# Target our system GLib version
sed -i 's/--target-glib=2\.82/--target-glib=2.80/' src/meson.build

meson setup build --prefix=/usr --buildtype=release \
    -Dsystemd-service=true \
    -Dman-pages=true
ninja -C build

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C build install

make_deb "$PKG" "$VER" "Sway/Wayland notification center (GTK4)" "$STAGE" \
    "gtk4-hypr, libadwaita-hypr, granite-7-hypr, gtk4-layer-shell, libgee-0.8-2, libjson-glib-1.0-0, libpulse0, libwayland-client0" \
    "swaync"
