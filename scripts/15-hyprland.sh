#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

PKG=hyprland
VER=0.55.2

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii.*$VER"; then
    echo "$PKG $VER already installed"
    exit 0
fi

HYPR_SOURCE="$BASE_DIR/HyprSource/hyprland-source"

if [ ! -d "$HYPR_SOURCE" ]; then
    mkdir -p "$BASE_DIR/HyprSource"
    cd "$BASE_DIR/HyprSource"
    wget -q --show-progress "https://github.com/hyprwm/Hyprland/releases/download/v$VER/source-v$VER.tar.gz"
    tar -xf "source-v$VER.tar.gz"
fi

cd "$HYPR_SOURCE"

export GIT_COMMIT_HASH="tarball"
export GIT_BRANCH="main"
export GIT_COMMIT_MESSAGE="v$VER"
export GIT_COMMIT_DATE="2025"
export GIT_DIRTY="clean"
export GIT_TAG="v$VER"
export GIT_COMMITS="0"

cmake -B build \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=g++-15 \
    -DCMAKE_C_COMPILER=gcc-15 \
    -DNO_SYSTEMD=ON \
    -DNO_XWAYLAND=OFF

cmake --build build -j$(nproc)

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" cmake --install build

make_deb "$PKG" "$VER" "Hyprland - A Modern C++ Wayland Compositor" "$STAGE" \
    "aquamarine, hyprlang, hyprcursor, hyprutils, hyprgraphics, hyprwire, libxkbcommon-hypr, libinput-hypr, muparser-hypr, lcms2-hypr, lua5.5-hypr, xcb-errors-hypr"
