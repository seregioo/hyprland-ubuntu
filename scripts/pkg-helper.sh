#!/bin/bash
# Helper functions for creating .deb packages
BASE_DIR="/home/ehidser/Desktop/stuff/git-repos/hyprland-ubuntu"
DEPS_DIR="$BASE_DIR/deps"
PKG_OUT="$BASE_DIR/packages"
mkdir -p "$PKG_OUT" "$DEPS_DIR"

export CC=gcc-15
export CXX=g++-15
export PATH="$BASE_DIR/prefix/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:${PKG_CONFIG_PATH:-}"

# make_deb PKG_NAME VERSION DESCRIPTION STAGE_DIR [DEPENDS] [CONFLICTS_AND_REPLACES]
make_deb() {
    local pkg_name="$1"
    local version="$2"
    local description="$3"
    local stage_dir="$4"
    local depends="${5:-}"
    local conflicts="${6:-}"

    mkdir -p "$stage_dir/DEBIAN"
    cat > "$stage_dir/DEBIAN/control" << EOF
Package: $pkg_name
Version: $version
Section: libs
Priority: optional
Architecture: amd64
Maintainer: ehidser
Depends: $depends
Conflicts: $conflicts
Replaces: $conflicts
Description: $description
EOF

    dpkg-deb --build --root-owner-group "$stage_dir" "${stage_dir}.deb"
    sudo dpkg --force-overwrite -i "${stage_dir}.deb"
    mv "${stage_dir}.deb" "$PKG_OUT/"
    rm -rf "$stage_dir"
    echo "=== $pkg_name $version → $PKG_OUT/ ==="
}
