#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=hyprwire
VER=0.3.1
if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
    NEW_VER=$(get_latest_version https://github.com/hyprwm/hyprwire.git v)
    if [[ -n "$NEW_VER" ]]; then VER="$NEW_VER"; fi
    if [[ "$(installed_version $PKG)" == "$VER" ]]; then
        echo "$PKG: already at $VER, skipping"
        exit 0
    fi
    echo "$PKG: updating to $VER"
    rm -rf "$DEPS_DIR/hyprwire"
elif dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "hyprwire" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/hyprwm/hyprwire.git
fi

cd hyprwire
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" cmake --install build

make_deb "$PKG" "$VER" "Hyprland wire protocol library" "$STAGE" "hyprutils"
