#!/bin/bash
set -e
source "$(dirname "$0")/../scripts/pkg-helper.sh"

PKG=awww
VER=0.12.1

if dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
    echo "$PKG already installed"
    exit 0
fi

echo "=== Building awww v$VER ==="

# System deps
sudo apt-get install -y liblz4-dev 2>&1 | tail -2

cd "$DEPS_DIR"
if [ ! -d "awww" ]; then
    git clone --depth 1 --branch "v$VER" https://codeberg.org/LGFae/awww.git
fi

cd awww
cargo build --release

# Stage
STAGE="$DEPS_DIR/${PKG}_${VER}_amd64"
rm -rf "$STAGE"
mkdir -p "$STAGE/usr/bin"
cp target/release/awww "$STAGE/usr/bin/"
cp target/release/awww-daemon "$STAGE/usr/bin/" 2>/dev/null || true

make_deb "$PKG" "$VER" "Efficient animated wallpaper daemon for Wayland" "$STAGE" "liblz4-1, libwayland-client0"
