#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building xkbcommon 1.13.1 ==="
cd "$DEPS_DIR"

VERSION="1.13.1"
if pkg-config --atleast-version=1.11.0 xkbcommon 2>/dev/null; then
    echo "xkbcommon already satisfied: $(pkg-config --modversion xkbcommon)"
    exit 0
fi

if [ ! -d "libxkbcommon-xkbcommon-$VERSION" ]; then
    wget -q --show-progress "https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-$VERSION.tar.gz"
    tar -xf "xkbcommon-$VERSION.tar.gz"
fi

cd "libxkbcommon-xkbcommon-$VERSION"
rm -rf build
meson setup build --prefix="$PREFIX" --buildtype=release \
    -Denable-docs=false \
    -Denable-wayland=true \
    -Denable-x11=true \
    -Denable-bash-completion=false
ninja -C build
ninja -C build install

echo "=== xkbcommon installed: $(pkg-config --modversion xkbcommon) ==="
