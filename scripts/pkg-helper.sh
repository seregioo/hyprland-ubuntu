#!/bin/bash
# Helper functions for creating .deb packages
BASE_DIR="/home/ehidser/Desktop/stuff/git-repos/hyprland-ubuntu"
DEPS_DIR="$BASE_DIR/deps"
PKG_OUT="$BASE_DIR/packages"
DEFERRED_DEBS="$BASE_DIR/.deferred-debs"
mkdir -p "$PKG_OUT" "$DEPS_DIR"

export CC=gcc-15
export CXX=g++-15
export PATH="$BASE_DIR/prefix/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:${PKG_CONFIG_PATH:-}"

# get_latest_version REPO TAG_PREFIX
# Fetches latest version from a git remote. TAG_PREFIX is stripped from the tag name.
# Returns empty string on failure — callers should fallback to hardcoded VER.
get_latest_version() {
    local repo="$1"
    local prefix="${2:-v}"
    timeout 10 git ls-remote --tags --refs "$repo" 2>/dev/null \
        | grep -oP "refs/tags/\K${prefix}[0-9]+\.[0-9]+(\.[0-9]{1,2})?$" \
        | sed "s/^${prefix}//" \
        | sort -V | tail -1
}

# installed_version PKG_NAME — returns installed version or empty
installed_version() {
    dpkg-query -W -f='${Version}' "$1" 2>/dev/null || true
}

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
    mv "${stage_dir}.deb" "$PKG_OUT/"
    rm -rf "$stage_dir"

    if [[ "${UPDATE_MODE:-0}" == "1" ]]; then
        # Defer install — record for batch install at end
        echo "$PKG_OUT/${pkg_name}_${version}_amd64.deb" >> "$DEFERRED_DEBS"
        echo "=== $pkg_name $version built (install deferred) ==="
    else
        sudo dpkg --force-overwrite -i "$PKG_OUT/${pkg_name}_${version}_amd64.deb"
        echo "=== $pkg_name $version → $PKG_OUT/ ==="
    fi
}
