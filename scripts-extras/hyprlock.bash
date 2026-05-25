#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/pkg-helper.sh"

# --- sdbus-c++ 2.1.0 ---
if ! pkg-config --atleast-version=2.0.0 sdbus-c++ 2>/dev/null; then
    echo "=== Building sdbus-c++ 2.1.0 ==="
    cd "$DEPS_DIR"
    if [ ! -d "sdbus-cpp" ]; then
        git clone --depth 1 --branch v2.1.0 https://github.com/Kistler-Group/sdbus-cpp.git
    fi
    cd sdbus-cpp
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_LIBSYSTEMD=OFF
    cmake --build build -j$(nproc)
    STAGE="$DEPS_DIR/sdbus-cpp-hypr_2.1.0_amd64"
    rm -rf "$STAGE"
    DESTDIR="$STAGE" cmake --install build
    make_deb "sdbus-cpp-hypr" "2.1.0" "High-level C++ D-Bus library" "$STAGE" "libsystemd0"
fi

# --- hyprlock ---
PKG=hyprlock
VER=0.9.5

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "hyprlock" ]; then
    git clone --depth 1 --branch "v$VER" https://github.com/hyprwm/hyprlock.git
fi

cd hyprlock
rm -rf build
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)

STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
DESTDIR="$STAGE" cmake --install build

make_deb "$PKG" "$VER" "Hyprland screen lock utility" "$STAGE" "hyprutils, hyprlang, hyprgraphics, sdbus-cpp-hypr"
