#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building wayland-protocols 1.48 ==="
cd "$DEPS_DIR"

VERSION="1.48"
if pkg-config --atleast-version=1.47 wayland-protocols 2>/dev/null; then
    echo "wayland-protocols already satisfied: $(pkg-config --modversion wayland-protocols)"
    exit 0
fi

if [ ! -d "wayland-protocols-$VERSION" ]; then
    wget -q --show-progress "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/$VERSION/downloads/wayland-protocols-$VERSION.tar.xz"
    tar -xf "wayland-protocols-$VERSION.tar.xz"
fi

cd "wayland-protocols-$VERSION"
meson setup build --prefix="$PREFIX" --buildtype=release
ninja -C build
ninja -C build install

echo "=== wayland-protocols installed: $(pkg-config --modversion wayland-protocols) ==="
