#!/bin/bash
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building libinput 1.28.0 ==="
cd "$DEPS_DIR"

VERSION="1.28.0"
if pkg-config --atleast-version=1.28 libinput 2>/dev/null; then
    echo "libinput already satisfied: $(pkg-config --modversion libinput)"
    exit 0
fi

if [ ! -d "libinput-$VERSION" ]; then
    wget -q --show-progress "https://gitlab.freedesktop.org/libinput/libinput/-/archive/$VERSION/libinput-$VERSION.tar.gz"
    tar -xf "libinput-$VERSION.tar.gz"
fi

cd "libinput-$VERSION"
meson setup build --prefix="$PREFIX" --buildtype=release \
    -Ddocumentation=false \
    -Dtests=false \
    -Ddebug-gui=false
ninja -C build
ninja -C build install

echo "=== libinput installed: $(pkg-config --modversion libinput) ==="
