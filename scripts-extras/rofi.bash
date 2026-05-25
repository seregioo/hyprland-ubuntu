#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPS_DIR="$BASE_DIR/deps"
VERSION="1.7.9"
PKG_NAME="rofi-wayland"
PKG_DIR="$DEPS_DIR/${PKG_NAME}_${VERSION}_amd64"

echo "=== Building rofi-wayland $VERSION as .deb package ==="

if dpkg -l "$PKG_NAME" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG_NAME already installed"
    exit 0
fi

cd "$DEPS_DIR"
if [ ! -d "rofi-wayland" ]; then
    git clone --depth 1 --branch "${VERSION}+wayland1" https://github.com/lbonn/rofi.git rofi-wayland
    cd rofi-wayland
    git submodule update --init --depth 1
else
    cd rofi-wayland
fi

if [ ! -f build/rofi ]; then
    meson setup build --prefix=/usr --buildtype=release
    ninja -C build
fi

# Install to staging directory
echo "[1/2] Staging install..."
rm -rf "$PKG_DIR"
DESTDIR="$PKG_DIR" ninja -C build install

# Create DEBIAN control file
mkdir -p "$PKG_DIR/DEBIAN"
cat > "$PKG_DIR/DEBIAN/control" << EOF
Package: $PKG_NAME
Version: $VERSION
Section: x11
Priority: optional
Architecture: amd64
Maintainer: ehidser
Depends: libglib2.0-0, libcairo2, libpango-1.0-0, libwayland-client0, libxkbcommon0, libgdk-pixbuf-2.0-0, libstartup-notification0
Provides: rofi
Conflicts: rofi
Replaces: rofi
Description: Rofi window switcher (Wayland fork)
 A window switcher, application launcher and dmenu replacement.
 This is the Wayland-native fork by lbonn.
EOF

# Build .deb
echo "[2/2] Building .deb..."
dpkg-deb --build "$PKG_DIR"

# Install it
echo "Installing..."
sudo dpkg -i "${PKG_DIR}.deb"

# Move .deb to packages dir
mkdir -p "$BASE_DIR/packages"
mv "${PKG_DIR}.deb" "$BASE_DIR/packages/"

echo ""
echo "=== Done! ==="
echo "Installed: $(rofi -version)"
echo "Package at: $BASE_DIR/packages/${PKG_NAME}_${VERSION}_amd64.deb"
echo "Remove with: sudo apt remove $PKG_NAME"
