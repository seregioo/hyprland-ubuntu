#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building libdisplay-info 0.2.0 ==="
cd "$DEPS_DIR"

VERSION="0.2.0"
if pkg-config --exists libdisplay-info 2>/dev/null; then
    echo "libdisplay-info already satisfied: $(pkg-config --modversion libdisplay-info)"
    exit 0
fi

if [ ! -d "libdisplay-info-$VERSION" ]; then
    wget -q --show-progress "https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/$VERSION/downloads/libdisplay-info-$VERSION.tar.xz"
    tar -xf "libdisplay-info-$VERSION.tar.xz"
fi

cd "libdisplay-info-$VERSION"
meson setup build --prefix="$PREFIX" --buildtype=release
ninja -C build
ninja -C build install

echo "=== libdisplay-info installed: $(pkg-config --modversion libdisplay-info) ==="
