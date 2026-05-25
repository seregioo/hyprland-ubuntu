#!/bin/bash
set -e
source "$(dirname "$0")/pkg-helper.sh"

# --- muparser ---
PKG=muparser-hypr
VER=2.3.5
if ! dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    cd "$DEPS_DIR"
    if [ ! -d "muparser" ]; then
        git clone --depth 1 --branch "v$VER" https://github.com/beltoforion/muparser.git
    fi
    cd muparser
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DENABLE_SAMPLES=OFF -DENABLE_OPENMP=OFF
    cmake --build build -j$(nproc)
    STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
    rm -rf "$STAGE"
    DESTDIR="$STAGE" cmake --install build
    make_deb "$PKG" "$VER" "Mathematical expression parser library" "$STAGE"
else
    echo "$PKG already installed"
fi

# --- lcms2 ---
PKG=lcms2-hypr
VER=2.16
if ! dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    cd "$DEPS_DIR"
    if [ ! -d "Little-CMS" ]; then
        git clone --depth 1 --branch lcms2.16 https://github.com/mm2/Little-CMS.git
    fi
    cd Little-CMS
    rm -rf build
    meson setup build --prefix=/usr --buildtype=release
    ninja -C build
    STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
    rm -rf "$STAGE"
    DESTDIR="$STAGE" ninja -C build install
    make_deb "$PKG" "$VER" "Little CMS 2 color management library" "$STAGE"
else
    echo "$PKG already installed"
fi
